# ActiveSupport 6.0 changed :parent -> :module_parent
# This eliminates deprecation messages so everything works like v5.2 and prior.

module NCore
  module ModuleFix
    extend ActiveSupport::Concern

      included do
        alias :parent :module_parent
      end

  end
end

if Module.respond_to?(:module_parent)
  Module.include NCore::ModuleFix
end
