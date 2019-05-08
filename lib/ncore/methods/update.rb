module NCore
  module Update
    extend ActiveSupport::Concern

    module ClassMethods
      def update!(id, attribs)
        obj = update(id, attribs)
        if obj.errors?
          raise module_parent::RecordInvalid, obj
        end
        obj
      end

      # always returns a new object; check .errors? or .valid? to see how it went
      def update(id, attribs)
        raise(module_parent::RecordNotFound, "Cannot update id=nil") if id.blank?
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
      update(params) || raise(self.class.module_parent::RecordInvalid, self)
    end

  end
end
