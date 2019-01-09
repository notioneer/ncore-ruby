module NCore
  module Update
    extend ActiveSupport::Concern

    module ClassMethods
      def update!(id, attribs)
        obj = update(id, attribs)
        if obj.errors?
          raise parent::RecordInvalid, obj
        end
        obj
      end

      # always returns a new object; check .errors? or .valid? to see how it went
      def update(id, attribs)
        raise(parent::RecordNotFound, "Cannot update id=nil") if id.blank?
        obj = new(id: id)
        obj.update attribs
        obj
      end
    end

    def update(attribs={})
      params = parse_request_params(attribs, json_root: json_root).reverse_merge credentials: api_creds
      parsed, @api_creds = request(:put, url, params)
      load(data: params[json_root]) if parsed[:errors].any?
      load(parsed)
      errors.empty? ? self : false
    end

    def update!(params={})
      update(params) || raise(self.class.parent::RecordInvalid, self)
    end

  end
end
