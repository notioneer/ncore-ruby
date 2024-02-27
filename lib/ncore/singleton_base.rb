module NCore
  module SingletonBase
    extend ActiveSupport::Concern

    included do
      extend Associations
      include ActiveModel
      include Attributes
      include Client
      include FilterAttributes
      include Identity
      include Lifecycle
      include Util
      include Wait

      self.filter_attributes = []
    end

    module ClassMethods
      def crud(*types)
        include Build        if types.include? :build
        include Create       if types.include? :create
        include DeleteSingle if types.include? :delete
        include FindSingle   if types.include? :find
        include Update       if types.include? :update
      end

      def resource_path
        class_name.underscore
      end
    end

    def resource_path
      self.class.resource_path
    end

  end
end
