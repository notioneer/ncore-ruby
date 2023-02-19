module NCore
  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      def find(id, params={})
        raise(module_parent::RecordNotFound, "Cannot find id=nil") if id.blank?
        o = new({id: id})
        o.reload(params)
      end

      def retrieve(id, params={})
        find id, params
      rescue module_parent::RecordNotFound
        nil
      end
    end

    def reload(find_params={})
      return if id.blank?
      params = parse_request_params(find_params).reverse_merge credentials: api_creds
      parsed, @api_creds = request(:get, resource_path, params)
      @attribs = {}.with_indifferent_access
      load(parsed)
    end

  end
end
