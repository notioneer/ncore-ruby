module NCore
  module Delete
    extend ActiveSupport::Concern

    module ClassMethods
      def delete!(id, params={}, api_creds=nil)
        obj = new({id: id}, api_creds)
        obj.delete(params) || raise(parent::RecordInvalid, obj)
      end

      # always returns a new object; check .errors? or .valid? to see how it went
      def delete(id, params={}, api_creds=nil)
        obj = new({id: id}, api_creds)
        obj.delete(params)
        obj
      end
    end

    def delete(params={})
      parsed, @api_creds = request(:delete, url, api_creds, params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
