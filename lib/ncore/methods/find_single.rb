module NCore
  module FindSingle
    extend ActiveSupport::Concern

    module ClassMethods
      def find(params={}, api_creds=nil)
        parsed, creds = request(:get, url, api_creds, params)
        if parsed[:errors].any?
          raise parent::QueryError, parsed[:errors]
        end
        new(parsed, creds)
      end

      def retrieve(params={}, api_creds=nil)
        find params, api_creds
      rescue parent::RecordNotFound
        false
      end
    end

    def id
      'singleton'
    end

    private

    def reload(find_params={})
      parsed, @api_creds = request(:get, url, api_creds, find_params)
      @attribs = {}.with_indifferent_access
      load(parsed)
    end

  end
end
