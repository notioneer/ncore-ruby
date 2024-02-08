module NCore
  module Attributes
    extend ActiveSupport::Concern

    included do
      attr :id
    end


    module ClassMethods
      # attr(:name, ...)
      #   adds: obj.name  => raw json type
      #         obj.name? => bool
      def attr(*attrs, predicate: true)
        attrs.each do |attr|
          check_existing_method(attr)
          class_eval <<-AR, __FILE__, __LINE__+1
            def #{attr}
              self[:#{attr}]
            end
          AR
          attr_boolean :"#{attr}?" if predicate
        end
      end

      # attr_datetime(:updated_at, ...)
      #   adds: obj.updated_at  => Time, or raw json type if not parseable
      #         obj.updated_at? => bool
      def attr_datetime(*attrs, predicate: true)
        attrs.each do |attr|
          check_existing_method(attr)
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
          attr_boolean :"#{attr}?" if predicate
        end
      end

      # attr_decimal(:amount, ...)
      #   adds: obj.amount  => BigMoney if String, else raw json type
      #         obj.amount? => bool
      def attr_decimal(*attrs, predicate: true)
        attrs.each do |attr|
          check_existing_method(attr)
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
          attr_boolean :"#{attr}?" if predicate
        end
      end

      # attr_boolean(:active, :active?, ...)
      #   adds: obj.active
      #   adds: obj.active? - in attrs hash, this looks for the key :active, not :active?
      def attr_boolean(*attrs)
        attrs.each do |attr|
          check_existing_method(attr)
          class_eval <<-AB, __FILE__, __LINE__+1
            def #{attr}
              !! self[:#{attr.to_s.sub(/\?$/,'')}]
            end
          AB
        end
      end

      def check_existing_method(attr)
        if method_defined?(attr) || private_method_defined?(attr)
          sc = self
          sc = sc.superclass while sc.superclass != Object
          warn "Warning: Existing method #{sc.name}##{attr} being overwritten at #{caller[3]}"
        end
      end

      def parse_request_params(params={}, opts={})
        params = params.with_indifferent_access
        req = params.delete(:request)
        hdr = params.delete(:headers)
        creds = params.delete(:credentials)
        cache = params.delete(:cache)
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
        o[:headers] = hdr if hdr
        o[:credentials] = creds if creds
        o[:cache] = cache if cache
        o
      end
    end

    def parse_request_params(params, opts={})
      self.class.parse_request_params(params, opts)
    end


    attr_accessor :api_creds
    attr_accessor :metadata, :errors


    def initialize(attribs={}, api_creds=nil, options={})
      @attribs   = {}.with_indifferent_access
      attribs    = attribs.dup.with_indifferent_access
      preload    = options[:preload].present? ? options[:preload].dup.with_indifferent_access : nil
      creds_attr = attribs.delete(:credentials)
      @api_creds = api_creds || creds_attr

      if preload
        load(data: preload.delete(:data) || preload.except(:credentials, :metadata, :errors))
      end

      load(
        metadata: attribs.delete(:metadata),
        errors: attribs.delete(:errors),
        data: attribs.delete(:data) || attribs
      )
    end


    def attributes
      Util.deep_clone(@attribs)
    end
    alias_method :as_json, :attributes

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


    def load(args={})
      raise ArgumentError, "Missing :data" unless args.key?(:data)
      extra_keys = args.keys - %i(data errors metadata)
      raise ArgumentError, "Unexpected keys: #{extra_keys.inpsect}" if extra_keys.any?

      self.metadata = args[:metadata] || {}.with_indifferent_access
      self.errors = parse_errors(args[:errors])
      args[:data].each do |k,v|
        if k=='metadata' || k=='errors'
          @attribs[k] = self.class.interpret_type(v, api_creds)
        elsif respond_to?("#{k}=")
          send "#{k}=", self.class.interpret_type(v, api_creds)
        else
          @attribs[k] = self.class.interpret_type(v, api_creds)
        end
      end
      self
    end

    def parse_errors(errors)
      errors ||= []
      if errors.is_a?(::ActiveModel::Errors)
        errors
      else
        ::ActiveModel::Errors.new(self).tap do |e0|
          errors.each{|msg| e0.add :base, msg }
        end
      end
    end

  end


  class BigMoney < SimpleDelegator

    def initialize(*args)
      __setobj__(BigDecimal(*args))
    end

    def to_s
      if (self % BigDecimal('0.01')) == 0
        '%.2f' % self
      else
        super
      end
    end

  end
end
