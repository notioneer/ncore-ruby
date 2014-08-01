module NCore
  module Create
    extend ActiveSupport::Concern

    module ClassMethods
      def create!(attribs={}, api_creds=nil)
        obj = create(attribs, api_creds)
        if obj.errors.any?
          raise parent::RecordInvalid, obj
        end
        obj
      end

      # always returns a new object; check .errors? or .valid? to see how it went
      def create(attribs={}, api_creds=nil)
        params = {json_root => attribs}
        parsed, creds = request(:post, url, api_creds, params)
        new(attribs, creds).send(:load, parsed)
      end
    end

    private

    def create(attribs={})
      params = {json_root => attribs}
      parsed, @api_creds = request(:post, self.class.url, api_creds, params)
      load(data: attribs) if parsed[:errors].any?
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
