require 'action_controller'

module NCore
  module ActionController
    module Parameters
      extend ActiveSupport::Concern

      included do
        alias :with_indifferent_access :to_h
      end

    end
  end
end


if defined?(ActionController::Parameters)
  acp = ActionController::Parameters.new
  unless acp.respond_to? :with_indifferent_access
    ActionController::Parameters.include NCore::ActionController::Parameters
  end
end
