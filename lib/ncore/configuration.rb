module NCore
  module Configuration
    extend ActiveSupport::Concern

    included do
      init_config_options
    end


    module ClassMethods

      def init_config_options
        mattr_writer :default_url
        class_eval <<-MTH
          def self.default_url
            self.default_url = @@default_url.call if @@default_url.respond_to? :call
            @@default_url
          end
          def default_url
            self.default_url = @@default_url.call if @@default_url.respond_to? :call
            @@default_url
          end
        MTH
        self.default_url = 'https://api.example.com/v1/'

        mattr_accessor :default_headers
        self.default_headers = {
          accept: 'application/json',
          content_type: 'application/json',
          user_agent: "NCore/ruby v#{VERSION}"
        }

        mattr_writer :credentials
        class_eval <<-MTH
          def self.credentials
            self.credentials = @@credentials.call if @@credentials.respond_to? :call
            @@credentials
          end
          def credentials
            self.credentials = @@credentials.call if @@credentials.respond_to? :call
            @@credentials
          end
        MTH

        mattr_accessor :debug
        self.debug = false

        mattr_accessor :strict_attributes
        self.strict_attributes = true

        mattr_accessor :i18n_scope
        self.i18n_scope = :ncore

        mattr_accessor :instrument_key
        self.instrument_key = 'request.ncore'

        mattr_accessor :status_page
        self.status_page = 'the status page'

        mattr_accessor :auth_header_prefix
        self.auth_header_prefix = 'x-api'

        mattr_reader :bearer_credential_key
        class_eval <<-MTH
          def self.bearer_credential_key=(v)
            @@bearer_credential_key = v&.to_s
          end
          def bearer_credential_key=(v)
            @@bearer_credential_key = v&.to_s
          end
        MTH

        mattr_accessor :credentials_error_message
        self.credentials_error_message = %Q{Missing API credentials. Set default credentials using "#{self.module_parent.name}.credentials = {api_user: YOUR_API_USER, api_key: YOUR_API_KEY}"}

        mattr_accessor :verify_ssl
        self.verify_ssl = true

        mattr_reader :ssl_cert_bundle
        class_eval <<-MTH
          def self.ssl_cert_bundle=(v)
            v = find_excon_bundle if v==:bundled
            @@ssl_cert_bundle = v
          end
          def ssl_cert_bundle=(v)
            v = find_excon_bundle if v==:bundled
            @@ssl_cert_bundle = v
          end
        MTH

        mattr_accessor :cache_store

        mattr_accessor :logger
        self.logger = Logger.new(STDOUT)
      end


      private

      def find_excon_bundle
        b = Gem.find_files_from_load_path('../data/cacert.pem').select{|p| p=~/excon/}.first
        if b
          b.freeze
        else
          raise module_parent::CertificateError, 'Failed to locate CA cert bundle from excon. Specify a full path instead.'
        end
      end

    end

  end
end
