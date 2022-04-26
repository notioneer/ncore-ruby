require 'json'

module NCore
  module Client
    extend ActiveSupport::Concern

    module ClassMethods

      # opts - {params: {}, headers: {}, credentials: {}, cache: {}}
      #   unknown keys assumed to be :params if :params is missing
      def request(method, url, opts={})
        opts = opts.with_indifferent_access
        request_credentials = opts.delete 'credentials'
        cache_opts = opts.delete 'cache'
        headers = opts.delete('headers') || {}
        params = opts['params'] || opts

        request_credentials ||= retrieve_credentials
        request_credentials = parse_credentials(request_credentials)

        base_url = request_credentials[:url] || retrieve_default_url
        base_url += '/' unless base_url.ends_with?('/')
        url = base_url + url

        headers = build_headers(headers, request_credentials.except(:url))

        path = URI.parse(url).path
        if [:get, :head, :delete].include? method
          qs = build_query_string params
          url += qs
          path += qs
          payload = nil
        else
          if defined? MultiJson
            payload = MultiJson.encode params
          else
            payload = JSON.generate params
          end
        end

        rest_opts = {
          body: payload,
          # connect_timeout: 10,
          headers: headers,
          method: method,
          path: path,
          read_timeout: 50,
          url: url,
          write_timeout: 50,
        }

        response = execute_request(rest_opts, cache_opts)
        parsed = parse_response(response)
        [parsed, request_credentials]
      end


      private

      def retrieve_credentials
        if credentials.blank?
          raise module_parent::Error, credentials_error_message
        end
        credentials
      end

      def parse_credentials(creds)
        creds.with_indifferent_access
      end

      def retrieve_default_url
        if default_url.blank?
          raise module_parent::Error, credentials_error_message
        end
        default_url
      end

      def build_headers(headers, req_credentials)
        h = {}
        [default_headers, auth_headers(req_credentials), headers].each do |set|
          set.each do |k,v|
            k = k.to_s.tr('_','-').gsub(%r{(^|-)\w}){$&.upcase}
            h[k] = v.respond_to?(:call) ? v.call : v
          end
        end
        h
      end

      def build_query_string(params)
        if params.any?
          query_string = params.sort.map do |k,v|
            if v.is_a?(Array)
              if v.empty?
                "#{k.to_s}[]="
              else
                v.sort.map do |v2|
                  "#{k.to_s}[]=#{CGI::escape(v2.to_s)}"
                end.join('&')
              end
            else
              "#{k.to_s}=#{CGI::escape(v.to_s)}"
            end
          end.join('&')
          "?#{query_string}"
        else
          ''
        end
      end


      def host_for_error(uri)
        u = URI.parse uri
        "#{u.host}:#{u.port}"
      rescue
        uri
      end


      # create a new excon client if necessary
      # keeps a pool of the last 10 urls
      #   in almost all cases this will be more than enough 
      def excon_client(uri)
        u = URI.parse uri
        u.path = ''
        u.user = u.password = u.query = nil
        addr = u.to_s

        if cl = pool[addr]
          unless pool.keys.last == addr
            pool.delete addr
            pool[addr] = cl # move it to the end
          end
          cl
        else
          if pool.size >= 10 # keep a max of ten at once
            to_close = pool.delete pool.keys.first
            to_close.reset
          end
          ex_opts = {
            connect_timeout: 10,
            persistent: true
          }
          if verify_ssl_cert?
            ex_opts.merge!(
              ssl_ca_file: ssl_cert_bundle,
              ssl_verify_peer: OpenSSL::SSL::VERIFY_PEER
            )
          else
            ex_opts.merge! ssl_verify_peer: false
          end
          pool[addr] = Excon.new(addr, ex_opts)
        end
      end

      def pool
        Thread.current[:ncore_pool] ||= {}
      end

      def reset_pool
        pool.each do |addr, cl|
          cl.reset
        end
        pool.clear
      end


      def execute_request(rest_opts, _)
        debug_request rest_opts if debug

        tries = 0
        response = nil
        begin
          ActiveSupport::Notifications.instrument(instrument_key, rest_opts) do

            connection = excon_client(rest_opts[:url])
            begin
              tries += 1
              response = connection.request rest_opts.except(:url)
            rescue Excon::Error::Socket, Excon::Errors::SocketError, Excon::Error::Timeout,
                Errno::EADDRNOTAVAIL, Errno::ECONNRESET => e
              # retry when keepalive was closed
              if tries <= 1
                retry
              else
                raise e
              end
            end
            rest_opts[:status] = response.status rescue nil
            debug_response response if debug
          end
        rescue Errno::ECONNRESET
          raise module_parent::ConnectionError, "Connection reset for #{host_for_error rest_opts[:url]} : check network or visit #{status_page}."
        rescue Errno::ECONNREFUSED
          raise module_parent::ConnectionError, "Connection error for #{host_for_error rest_opts[:url]} : check network and DNS or visit #{status_page}."
        rescue Excon::Error::Timeout => e
          case e.message
          when /timeout reached/
            raise module_parent::ConnectionError, "Connection error for #{host_for_error rest_opts[:url]} : check network and DNS or visit #{status_page}."
          else
            raise e
          end
        rescue Excon::Errors::SocketError => e
          case e.message
          when /Unable to verify certificate/
            raise module_parent::ConnectionError, "Unable to verify certificate for #{host_for_error rest_opts[:url]} : verify URL, set ssl_cert_bundle=, or disable SSL certificate verification (insecure)."
          when /Name or service not known/, /No address associated with hostname/
            raise module_parent::ConnectionError, "DNS error for #{host_for_error rest_opts[:url]} : check network and DNS or visit #{status_page}."
          when /Errno::ECONNREFUSED/
            raise module_parent::ConnectionError, "Connection error for #{host_for_error rest_opts[:url]} : check network and DNS or visit #{status_page}."
          else
            raise e
          end
        rescue SocketError => e
          if e.message =~ /nodename nor servname provided/
            raise module_parent::ConnectionError, "DNS error for #{host_for_error rest_opts[:url]} : check network and DNS or visit #{status_page}."
          else
            raise e
          end
        end

        case response.status
        when 401 # API auth valid; API call itself is an auth-related call and failed
          raise module_parent::AuthenticationFailed
        when 402
          raise module_parent::AccountInactive, "Account inactive; login to portal to check account status."
        when 403 # API auth failed or insufficient permissions
          raise module_parent::AccessDenied, "Access denied; check your API credentials and permissions."
        when 404
          raise module_parent::RecordNotFound
        when 409, 422
          # pass through
        when 429
          raise module_parent::RateLimited
        when 400..499
          raise module_parent::Error, "Client error: #{response.status}\n  #{response.body}"
        when 500..599
          raise module_parent::Error, "Server error: #{response.status}\n  #{response.body}"
        end
        response
      end

      def parse_response(response)
        if response.body.blank?
          json = {}
        else
          if defined? MultiJson
            begin
              json = MultiJson.load(response.body, symbolize_keys: false) || {}
            rescue MultiJson::ParseError
              raise module_parent::Error, "Unable to parse API response; HTTP status: #{response.status}; body: #{response.body.inspect}"
            end
          else
            begin
              json = JSON.parse(response.body, symbolize_names: false) || {}
            rescue JSON::ParserError
              raise module_parent::Error, "Unable to parse API response; HTTP status: #{response.status}; body: #{response.body.inspect}"
            end
          end
        end
        json = json.with_indifferent_access
        errors = json.delete(:errors) || []
        if errors.any?
          errors = errors.values.flatten if errors.is_a?(Hash)
          metadata, json = json, {}
        else
          errors = []
          if json[:collection]
            data = json.delete :collection
            metadata, json = json, data
            json = [] if json.blank?
          else
            metadata = nil
          end
        end
        if response.status == 215
          metadata, json = json, {}.with_indifferent_access
        end
        if [409, 422].include?(response.status) && errors.empty?
          errors.push 'Validation error'
        end
        {data: json, errors: errors, metadata: metadata}
      end


      def auth_headers(creds)
        creds.inject({}) do |h,(k,v)|
          if v.present?
            if k == bearer_credential_key
              h["Authorization"] = "Bearer #{v}"
            else
              h["#{auth_header_prefix}-#{k}"] = v 
            end
          end
          h
        end
      end

      def verify_ssl_cert?
        return @verify_ssl_cert unless @verify_ssl_cert.nil?
        if verify_ssl
          if ssl_cert_bundle
            bundle_readable = File.readable?(ssl_cert_bundle) rescue false
            unless bundle_readable
              raise module_parent::CertificateError, "Unable to read SSL cert bundle #{ssl_cert_bundle}."
            end
          end
          @verify_ssl_cert = true
        else
          m = "WARNNG: SSL cert verification is disabled. Enable verification with: #{module_parent}::Api.verify_ssl = true."
          $stderr.puts m
          @verify_ssl_cert = false
        end
      end

      def debug_request(rest_opts)
        return unless logger.debug?
        logger << <<-DBG
#{'-=- '*18}
REQUEST:
  #{rest_opts[:method].to_s.upcase} #{rest_opts[:url]}
  #{rest_opts[:headers].map{|h,d| "#{h}: #{d}"}.join("\n  ")}
  #{rest_opts[:body] || 'nil'}
DBG
      end

      def debug_response(response)
        return unless logger.debug?
        if defined? MultiJson
          json = MultiJson.load(response.body||'', symbolize_keys: false) rescue response.body
        else
          json = JSON.parse(response.body||'', symbolize_names: false) rescue response.body
        end
        logger << <<-DBG
RESPONSE:
  #{response.headers['Status']} | #{response.headers['Content-Type']} | #{response.body.size} bytes
  #{response.headers.except('Status', 'Connection', 'Content-Type').map{|h,d| "#{h}: #{d}"}.join("\n  ")}
  #{json.pretty_inspect.split("\n").join("\n  ")}
#{'-=- '*18}
DBG
      end

    end # ClassMethods


    def request(*args)
      self.class.request(*args)
    end

  end
end
