module MyApi
  class Railtie < Rails::Railtie

    initializer "my_api.log_runtime" do |app|
      require 'my_api/rails/log_subscriber'
      ActiveSupport.on_load(:action_controller) do
        include NCore::ControllerRuntime
        register_api_runtime MyApi::LogSubscriber, 'MyApi'
      end
    end

  end
end
