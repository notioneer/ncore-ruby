module NCore
  module Count
    extend ActiveSupport::Concern

    module ClassMethods
      def count(params={})
        params = parse_request_params(params)
        parsed, _ = request(:get, "#{resource_path}/count", params)
        parsed[:data][:count]
      end
    end

  end
end
