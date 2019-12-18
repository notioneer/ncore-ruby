module NCore
  module Client::Cache
    extend ActiveSupport::Concern

    module ClassMethods

      private

      # cache_opts: true
      #   use *::Api.cache_store
      # cache_opts: {...}
      #   use: *::Api.cache_store, with options: {...}
      #   hint: add  force: true  execute the query and rewrite the cache
      # cache_opts: Store.new
      #   use Store.new as-is
      def execute_request(req, cache_opts=nil)
        case cache_opts
        when true
          store, cache_opts = cache_store, {}
        when Hash
          store, cache_opts = cache_store, cache_opts.symbolize_keys
        when nil, false
          store = false
        else
          store, cache_opts = cache_opts, {}
        end

        if store && req[:method] == :get
          store.fetch request_cache_key(req.slice(:url, :headers)), cache_opts do
            super
          end
        else
          super
        end
      end


      def request_cache_key(url:, headers:)
        [ 'ncore',
          url.gsub(/[^a-zA-Z0-9]+/,'-'),
          Digest::MD5.hexdigest(headers.sort.to_s)
        ].join ':'
      end

    end

  end
end
