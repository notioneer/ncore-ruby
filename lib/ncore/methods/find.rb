module NCore
  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      def find(id, params={}, api_creds=nil)
        o = new({id: id}, api_creds)
        o.reload(params)
      end

      def retrieve(id, params={}, api_creds=nil)
        find id, params, api_creds
      rescue parent::RecordNotFound
        false
      end
    end

    def reload(find_params={})
      return if id.blank?
      parsed, @api_creds = request(:get, url, api_creds, find_params)
      @attribs = {}.with_indifferent_access
      load(parsed)
    end

  end
end
