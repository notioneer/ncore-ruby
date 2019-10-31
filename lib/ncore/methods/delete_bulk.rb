module NCore
  module DeleteBulk
    extend ActiveSupport::Concern

    module ClassMethods
      def bulk_delete!(ids, params={})
        raise(module_parent::RecordNotFound, "ids must not be empty") if ids.blank?
        params[:ids] = ids
        params = parse_request_params(params)
        parsed, creds = request(:delete, resource_path, params)
        if parsed[:errors].any?
          raise module_parent::BulkActionError, parsed[:errors]
        else
          parsed[:metadata]
        end
      end

      def bulk_delete(ids, params={})
        bulk_delete!(ids, params)
      rescue module_parent::RecordNotFound, module_parent::BulkActionError
        false
      end
    end

  end
end
