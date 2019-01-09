module NCore
  module Create
    extend ActiveSupport::Concern

    module ClassMethods
      def create!(attribs={})
        obj = create(attribs)
        if obj.errors?
          raise parent::RecordInvalid, obj
        end
        obj
      end

      # always returns a new object; check .errors? or .valid? to see how it went
      def create(attribs={})
        obj = new
        obj.send :create, attribs
        obj
      end
    end

    private

    def create(attribs={})
      params = parse_request_params(attribs, json_root: json_root).reverse_merge credentials: api_creds
      parsed, @api_creds = request(:post, self.class.url, params)
      load(data: params[json_root]) if parsed[:errors].any?
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
