module NCore
  module Build
    extend ActiveSupport::Concern

    module ClassMethods
      def build(params={}, api_creds=nil)
        parsed, creds = request(:get, url+'/new', api_creds, params)
        if parsed[:errors].any?
          raise parent::QueryError, parsed[:errors]
        end
        new(parsed, creds)
      end
    end

  end
end
