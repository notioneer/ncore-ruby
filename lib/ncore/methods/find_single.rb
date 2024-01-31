module NCore
  module FindSingle
    extend ActiveSupport::Concern

    module ClassMethods
      def find(params={})
        obj = new
        obj.reload(params)
      end

      def retrieve(params={})
        find params
      rescue module_parent::RecordNotFound
        nil
      end
    end

    def id
      'singleton'
    end

    def reload(find_params={})
      params = parse_request_params(find_params).reverse_merge credentials: api_creds
      parsed, @api_creds = request(:get, resource_path, params)
      @attribs = {}.with_indifferent_access
      load(parsed)
    end

  end
end
