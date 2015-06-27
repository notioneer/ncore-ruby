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
        params = parse_request_params(attribs)
        obj = new({id: id}, params[:credentials])
        obj.update params
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

  end
end
