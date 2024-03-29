module MyApi
  include NCore::Builder

  configure do
    self.default_url = 'https://api.example.com/v1/'

    self.default_headers = {
      accept: 'application/json',
      content_type: 'application/json',
      user_agent: "MyApi/ruby v#{VERSION}"
    }

    if ENV['API_USER'] && ENV['API_KEY']
      self.credentials = {
        api_user: ENV['API_USER'],
        api_key:  ENV['API_KEY']
      }
    end

    self.debug = false

    self.strict_attributes = false

    self.i18n_scope = :my_api

    self.instrument_key = 'request.my_api'

    self.status_page = 'http://my.api.status.page'

    self.auth_header_prefix = 'x-myapi'

    # self.bearer_credential_key = :api_key

    self.credentials_error_message = %Q{Missing API credentials. Set default credentials using "MyApi.credentials = {api_user: YOUR_API_USER, api_key: YOUR_API_KEY}"}

    # self.verify_ssl = true

    # Uses system/OS bundle by default
    # self.ssl_cert_bundle = :bundled   # uses excon's included bundle
    # self.ssl_cert_bundle = 'path/to/bundle.crt'

    # self.logger = Logger.new(STDOUT)
  end

end
