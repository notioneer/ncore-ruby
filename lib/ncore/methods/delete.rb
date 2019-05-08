module NCore
  module Delete
    extend ActiveSupport::Concern

    module ClassMethods
      def delete!(id, params={})
        obj = delete(id, params)
        if obj.errors?
          raise module_parent::RecordInvalid, obj
        end
        obj
      end

      # always returns a new object; check .errors? or .valid? to see how it went
      def delete(id, params={})
        raise(module_parent::RecordNotFound, "Cannot delete id=nil") if id.blank?
        obj = new(id: id)
        obj.delete(params)
        obj
      end
    end

    def delete(params={})
      params = parse_request_params(params).reverse_merge credentials: api_creds
      parsed, @api_creds = request(:delete, url, params)
      load(parsed)
      errors.empty? ? self : false
    end

    def delete!(params={})
      delete(params) || raise(self.class.module_parent::RecordInvalid, self)
    end

  end
end
