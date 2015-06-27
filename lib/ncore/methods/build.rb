module NCore
  module Build
    extend ActiveSupport::Concern

    module ClassMethods
      def build(params={})
        params = parse_request_params(params)
        parsed, creds = request(:get, url+'/new', params)
        if parsed[:errors].any?
          raise parent::QueryError, parsed[:errors]
        end
        new(parsed, creds)
      end
    end

  end
end
