module NCore
  module All
    extend ActiveSupport::Concern

    module ClassMethods
      def all(params={})
        params = parse_request_params(params)
        parsed, creds = request(:get, url, params)
        if parsed[:errors].any?
          raise parent::QueryError, parsed[:errors]
        end
        Collection.new.tap do |coll|
          coll.metadata = parsed[:metadata]
          parsed[:data].each do |hash|
            if key = hash[:object]
              coll << discover_class(key, self).new(hash.merge(metadata: parsed[:metadata]), creds)
            else
              coll << new(hash.merge(metadata: parsed[:metadata]), creds)
            end
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
