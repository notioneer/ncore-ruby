module NCore
  module DeleteBulk
    extend ActiveSupport::Concern

    module ClassMethods
      def bulk_delete!(ids, params={})
        raise(parent::RecordNotFound, "ids must not be empty") if ids.blank?
        params[:ids] = ids
        params = parse_request_params(params)
        parsed, creds = request(:delete, url, params)
        if parsed[:errors].any?
          raise parent::BulkActionError, parsed[:errors]
        else
          parsed[:metadata]
        end
      end

      def bulk_delete(ids, params={})
        bulk_delete!(ids, params)
      rescue parent::RecordNotFound, parent::BulkActionError
        false
      end
    end

  end
end
