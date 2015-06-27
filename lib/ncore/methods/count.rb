module NCore
  module Count
    extend ActiveSupport::Concern

    module ClassMethods
      def count(params={})
        params = parse_request_params(params)
        parsed, _ = request(:get, "#{url}/count", params)
        parsed[:data][:count]
      end
    end

  end
end
