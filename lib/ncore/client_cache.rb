module NCore
  module Client::Cache
    extend ActiveSupport::Concern

    module ClassMethods

      private

      # only caches GET requests with 200..299, 409, 422 responses
      # cache_opts: true
      #   use *::Api.cache_store
      # cache_opts: {...}
      #   use: *::Api.cache_store, with options: {...}
      #   hint: add  force: true  to execute the query and rewrite the cache
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
          store.fetch request_cache_key(**req.slice(:url, :headers)), cache_opts do
            super
          end
        else
          super
        end
      end


      def request_cache_key(url:, headers:)
        hdrs = headers.reject{|k,v| k=='X-Request-Id'}.sort
        [ 'ncore',
          url.gsub(/[^a-zA-Z0-9]+/,'-'),
          Digest::MD5.hexdigest(hdrs.to_s)
        ].join(':')
      end

    end

  end
end
