module NCore
  module Update
    extend ActiveSupport::Concern

    module ClassMethods
      def update!(id, attribs, api_creds=nil)
        obj = new({id: id}, api_creds)
        obj.save!(attribs)
      end

      def update(id, attribs, api_creds=nil)
        obj = new({id: id}, api_creds)
        obj.save(attribs)
      end
    end


    private

    def update(attribs={})
      params = {json_root => attribs}
      parsed, @api_creds = request(:put, url, api_creds, params)
      load(data: attribs) if parsed[:errors].any?
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
