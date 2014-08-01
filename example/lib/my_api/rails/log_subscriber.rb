require 'ncore/rails/log_subscriber'

module AuthRocket
  class LogSubscriber < ActiveSupport::LogSubscriber
    include NCore::LogSubscriber
    self.runtime_variable = 'myapi_runtime'
  end
end

MyApi::LogSubscriber.attach_to :my_api
