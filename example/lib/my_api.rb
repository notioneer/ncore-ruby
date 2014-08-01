require 'ncore'

%w(version api_config).each do |f|
  require "my_api/#{f}"
end

%w(customer).each do |f|
  require "my_api/#{f}"
end

# optional; adds "MyApi: 16.3ms" to the Rails request log footer
require 'my_api/rails/railtie' if defined?(Rails)
