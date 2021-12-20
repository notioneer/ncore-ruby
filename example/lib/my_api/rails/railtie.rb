module MyApi
  class Railtie < Rails::Railtie

    config.action_dispatch.rescue_responses.merge!(
      'MyApi::RecordInvalid'  => :unprocessable_entity, # 422
      'MyApi::RecordNotFound' => :not_found, # 404
    )

    initializer "my_api.cache_store" do |app|
      MyApi::Api.cache_store = Rails.cache
    end

    initializer "my_api.log_runtime" do |app|
      require 'my_api/rails/log_subscriber'
      ActiveSupport.on_load(:action_controller) do
        include NCore::ControllerRuntime
        register_api_runtime MyApi::LogSubscriber, 'MyApi'
      end
    end

  end
end
