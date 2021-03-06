module NCore
  module DeleteSingle
    extend ActiveSupport::Concern

    module ClassMethods
      def delete(params={})
        obj = new
        obj.delete!(params)
      end
    end

    def delete(params={})
      params = parse_request_params(params).reverse_merge credentials: api_creds
      parsed, @api_creds = request(:delete, resource_path, params)
      load(parsed)
      errors.empty? ? self : false
    end

    def delete!(params={})
      delete(params) || raise(self.class.module_parent::RecordInvalid, self)
    end

  end
end
