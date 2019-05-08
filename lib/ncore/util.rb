module NCore
  module Util
    extend ActiveSupport::Concern

    def self.deep_clone(value)
      case value
      when Hash
        cl = value.clone
        value.each{|k,v| cl[k] = deep_clone(v)}
        cl
      when Array
        cl = value.clone
        cl.clear
        value.each{|v| cl << deep_clone(v)}
        cl
      when NilClass, Numeric, TrueClass, FalseClass
        value
      else
        value.clone rescue value
      end
    end


    module ClassMethods

      def interpret_type(val_or_enum, api_creds)
        case val_or_enum
        when Hash
          if key = val_or_enum[:object]
            discover_class(key).new({data: val_or_enum}, api_creds)
          else
            val_or_enum
          end
        when Array
          val_or_enum.map{|v| interpret_type v, api_creds }
        else
          val_or_enum
        end
      end

      def factory(parsed, api_creds)
        if key = (parsed[:data] || parsed)[:object]
          discover_class(key, self).new(parsed, api_creds)
        else
          new(parsed, api_creds)
        end
      end


      private

      def discover_class(key, default_klass=module_parent::GenericObject)
        klass_name = key.to_s.camelize.singularize
        begin
          "#{module_name}::#{klass_name}".constantize
        rescue NameError => e
          default_klass
        end
      end

    end


    def inspect
      "#<#{self.class}:0x#{self.object_id.to_s(16)}> id: #{id.inspect}, attribs: #{@attribs.except(:id).inspect}, metadata: #{metadata.inspect}"
    end

  end
end
