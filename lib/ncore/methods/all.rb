module NCore
  module All
    extend ActiveSupport::Concern

    module ClassMethods
      def all(params={})
        params = parse_request_params(params)
        parsed, creds = request(:get, url, params)
        if parsed[:errors].any?
          raise module_parent::QueryError, parsed[:errors]
        end
        Collection.new.tap do |coll|
          coll.metadata = parsed[:metadata]
          parsed[:data].each do |hash|
            coll << factory(hash.merge(metadata: parsed[:metadata]), creds)
          end
        end
      end

      def first(params={})
        params = params.with_indifferent_access.merge(max_results: 1)
        all(params).first
      end
    end

  end
end
