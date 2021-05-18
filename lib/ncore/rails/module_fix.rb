# ActiveSupport 6.0 changed :parent -> :module_parent
# This continues to support AS <= 5.2.

module NCore
  module ModuleFix
    extend ActiveSupport::Concern

      included do
        alias :module_parent :parent
        alias :module_parent_name :parent_name
        alias :module_parents :parents
      end

  end
end

unless Module.respond_to?(:module_parent)
  Module.include NCore::ModuleFix
end
