module NCore
  module FindSingle
    extend ActiveSupport::Concern

    module ClassMethods
      def find(params={})
        params = parse_request_params(params)
        parsed, creds = request(:get, url, params)
        if parsed[:errors].any?
          raise parent::QueryError, parsed[:errors]
        end
        new(parsed, creds)
      end

      def retrieve(params={})
        find params
      rescue parent::RecordNotFound
        false
      end
    end

    def id
      'singleton'
    end

    private

    def reload(find_params={})
      params = parse_request_params(find_params).reverse_merge credentials: api_creds
      parsed, @api_creds = request(:get, url, params)
      @attribs = {}.with_indifferent_access
      load(parsed)
    end

  end
end
