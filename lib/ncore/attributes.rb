module NCore
  module Attributes
    extend ActiveSupport::Concern

    included do
      attr :id
    end


    module ClassMethods
      def attr(*attrs)
        attrs.each do |attr|
          class_eval <<-AR, __FILE__, __LINE__+1
            def #{attr}
              self[:#{attr}]
            end
          AR
        end
      end

      def attr_datetime(*attrs)
        attrs.each do |attr|
          class_eval <<-AD, __FILE__, __LINE__+1
            def #{attr}
              case self[:#{attr}]
              when String
                Time.parse(self[:#{attr}]).utc
              when Numeric
                Time.at(self[:#{attr}]).utc
              else
                self[:#{attr}]
              end
            rescue ArgumentError, TypeError
              self[:#{attr}]
            end
          AD
        end
      end

      def attr_decimal(*attrs)
        attrs.each do |attr|
          class_eval <<-AD, __FILE__, __LINE__+1
            def #{attr}
              case self[:#{attr}]
              when String
                BigMoney.new(self[:#{attr}])
              else
                self[:#{attr}]
              end
            end
          AD
        end
      end

      def parse_request_params(params={}, opts={})
        params = params.with_indifferent_access
        req = params.delete(:request)
        creds = params.delete(:credentials)
        if opts[:json_root]
          if params.key?(opts[:json_root])
            o = params
          else
            o = {opts[:json_root] => params}.with_indifferent_access
          end
        else
          o = params
        end
        o[:request] = req if req
        o[:credentials] = creds if creds
        o
      end
    end

    def parse_request_params(params, opts={})
      self.class.parse_request_params(params, opts)
    end


    attr_accessor :api_creds
    attr_accessor :metadata, :errors


    def initialize(attribs={}, api_creds=nil)
      @attribs   = {}.with_indifferent_access
      attribs    = attribs.dup.with_indifferent_access
      creds_attr = attribs.delete(:credentials)
      @api_creds = api_creds || creds_attr

      if attribs.keys.sort == %w(data error metadata)
        load_attrs = attribs
      else
        load_attrs = {
          metadata: attribs.delete(:metadata),
          errors: attribs.delete(:errors),
          data: attribs.delete(:data) || attribs
        }
      end
      load(load_attrs)
    end


    def attributes
      Util.deep_clone(@attribs)
    end


    def [](attr)
      @attribs[attr]
    end


    # Method names known to cause strange behavior in other libraries
    # where said libraries check for these methods to determine other
    # behavior.
    KNOWN_FALSE_TRIGGERS = %w(map each)

    def respond_to?(method, incl_private=false)
      m2 = method.to_s.sub(/(\?)$/,'')
      if method.to_s =~ /\=$/
        super
      elsif @attribs.has_key?(m2)
        true
      elsif !self.class.strict_attributes && !KNOWN_FALSE_TRIGGERS.include?(m2)
        true
      else
        super
      end
    end


    private

    def method_missing(method, *args, &block)
      case method.to_s
      when /(.+)\?$/
        if @attribs.has_key?($1) || respond_to?($1.to_sym)
          !! self[$1]
        else
          super
        end
      when /\=$/
        super
      else
        if @attribs.has_key?(method) || !self.class.strict_attributes
          self[method]
        else
          super
        end
      end
    end


    def load(parsed)
      self.metadata = parsed[:metadata] || {}.with_indifferent_access
      self.errors = parsed[:errors] || {}.with_indifferent_access
      parsed[:data].each do |k,v|
        if respond_to? "#{k}="
          send "#{k}=", self.class.interpret_type(v, api_creds)
        else
          @attribs[k] = self.class.interpret_type(v, api_creds)
        end
      end
      self
    end

  end


  class BigMoney < BigDecimal

    def to_s
      if (self % BigDecimal.new('0.01')) == 0
        '%.2f' % self
      else
        super
      end
    end

  end
end
