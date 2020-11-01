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

        mattr_accessor :instrument_key
        self.instrument_key = 'request.ncore'

        mattr_accessor :status_page
        self.status_page = 'the status page'

        mattr_accessor :auth_header_prefix
        self.auth_header_prefix = 'X-Api'

        mattr_accessor :bearer_credential_key

        mattr_accessor :credentials_error_message
        self.credentials_error_message = %Q{Missing API credentials. Set default credentials using "#{self.parent.name}.credentials = {api_user: YOUR_API_USER, api_key: YOUR_API_KEY}"}

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

        mattr_accessor :logger
        self.logger = Logger.new(STDOUT)
      end


      private

      def find_excon_bundle
        b = Gem.find_files_from_load_path('../data/cacert.pem').select{|p| p=~/excon/}.first
        if b
          b.freeze
        else
          raise parent::CertificateError, 'Failed to locate CA cert bundle from excon. Specify a full path instead.'
        end
      end

    end

  end
end
