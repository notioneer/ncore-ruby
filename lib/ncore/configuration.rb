module NCore
  module Configuration
    extend ActiveSupport::Concern

    included do
      init_config_options
    end


    module ClassMethods

      def init_config_options
        mattr_accessor :default_url
        self.default_url = 'https://api.example.com/v1/'

        mattr_accessor :default_headers
        self.default_headers = {
          accept: 'application/json',
          content_type: 'application/json',
          user_agent: "NCore/ruby v#{VERSION}"
        }

        mattr_accessor :credentials

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
        self.auth_header_prefix = 'X-Api'

        mattr_reader :bearer_credential_key
        class_eval <<-MTH
          def self.bearer_credential_key=(v)
            @@bearer_credential_key = v&.to_s
          end
        MTH

        mattr_accessor :credentials_error_message
        self.credentials_error_message = %Q{Missing API credentials. Set default credentials using "#{self.module_parent.name}.credentials = {api_user: YOUR_API_USER, api_key: YOUR_API_KEY}"}

        mattr_accessor :verify_ssl
        self.verify_ssl = true

        mattr_accessor :ssl_cert_bundle
        self.ssl_cert_bundle = File.dirname(__FILE__)+'/ssl/ca-certificates.crt'

        mattr_accessor :logger
        self.logger = Logger.new(STDOUT)
      end

    end

  end
end
