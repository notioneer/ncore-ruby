module NCore
  module Build
    extend ActiveSupport::Concern

    module ClassMethods
      def build(params={})
        params = parse_request_params(params)
        parsed, creds = request(:get, "#{resource_path}/new", params)
        if parsed[:errors].any?
          raise module_parent::QueryError, parsed[:errors]
        end
        new(parsed, creds)
      end
    end

  end
end
