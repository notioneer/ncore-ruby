module NCore
  module Update
    extend ActiveSupport::Concern

    module ClassMethods
      def update!(id, attribs, api_creds=nil)
        obj = new({id: id}, api_creds)
        obj.save!(attribs)
      end

      # always returns a new object; check .errors? or .valid? to see how it went
      def update(id, attribs, api_creds=nil)
        obj = new({id: id}, api_creds)
        obj.save(attribs)
        obj
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
