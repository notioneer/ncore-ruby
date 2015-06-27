module NCore
  module DeleteSingle
    extend ActiveSupport::Concern

    module ClassMethods
      def delete(params={})
        params = parse_request_params(params)
        obj = new({}, params[:credentials])
        obj.delete(params) || raise(parent::RecordInvalid, obj)
      end
    end

    def delete(params={})
      params = parse_request_params(params).reverse_merge credentials: api_creds
      parsed, @api_creds = request(:delete, url, params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
