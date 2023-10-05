module NCore
  module UpdateBulk
    extend ActiveSupport::Concern

    module ClassMethods
      def bulk_update!(ids, params={})
        raise(module_parent::RecordNotFound, "ids must not be empty") if ids.blank?
        params = parse_request_params(params, json_root: json_root)
        params[:ids] = ids
        parsed, _creds = request(:put, resource_path, params)
        if parsed[:errors].any?
          raise module_parent::BulkActionError, parsed[:errors]
        else
          parsed[:metadata]
        end
      end

      def bulk_update(ids, params={})
        bulk_update!(ids, params)
      rescue module_parent::RecordNotFound, module_parent::BulkActionError
        false
      end
    end

  end
end
