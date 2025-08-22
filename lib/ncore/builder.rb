module NCore
  module Builder
    extend ActiveSupport::Concern

    included do
      class_eval <<-INCL, __FILE__, __LINE__+1
        include NCore::Exceptions

        module Api
          include NCore::Configuration
        end

        class Resource
          extend Api
          include NCore::Base
        end
        class SingletonResource
          extend Api
          include NCore::SingletonBase
        end

        class GenericObject < Resource
        end

        class << self
          def configure(&block)
            Api.instance_eval(&block)
          end
        end
      INCL
    end

  end
end
