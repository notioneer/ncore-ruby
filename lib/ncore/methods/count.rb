module NCore
  module Count
    extend ActiveSupport::Concern

    module ClassMethods
      def count(params={}, api_creds=nil)
        parsed, _ = request(:get, "#{url}/count", api_creds, params)
        parsed[:data][:count]
      end
    end

  end
end
