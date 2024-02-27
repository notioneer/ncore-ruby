module NCore
  module FilterAttributes
    extend ActiveSupport::Concern

    module ClassMethods

      def filter_attributes
        @filter_attributes || superclass.filter_attributes
      end

      def filter_attributes=(filter_attributes)
        @inspection_filter = nil
        @filter_attributes = filter_attributes
      end

      def inspection_filter
        if @filter_attributes
          @inspection_filter ||= ActiveSupport::ParameterFilter.new @filter_attributes
        else
          superclass.inspection_filter
        end
      end

    end


    def inspect
      base = "#{self.class}:0x#{'%016x'%self.object_id} id: #{id.inspect}"
      inspect_chain = Thread.current[:inspect_chain] ||= []
      return "#<#{base}, ...>" if inspect_chain.include? self
      begin
        inspect_chain.push self
        attribs = @attribs.except(:id).each.with_object({}) do |(k,v),h|
          h[k] = v.nil? ? nil : self.class.inspection_filter.filter_param(k,v)
        end
        "#<#{base}, attribs: #{attribs.inspect}, metadata: #{metadata.inspect}>"
      ensure
        inspect_chain.pop
      end
    end

  end
end
