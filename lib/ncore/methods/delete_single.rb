module NCore
  module DeleteSingle
    extend ActiveSupport::Concern

    module ClassMethods
      def delete(params={}, api_creds=nil)
        obj = new({}, api_creds)
        obj.delete(params) || raise(parent::RecordInvalid, obj)
      end
    end

    def delete(params={})
      parsed, @api_creds = request(:delete, url, api_creds, params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
