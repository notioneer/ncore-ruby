module NCore
  module SingletonBase
    extend ActiveSupport::Concern

    included do
      extend Associations
      include Attributes
      include Client
      include Identity
      include Lifecycle
      include Util
    end

    module ClassMethods
      def crud(*types)
        include Build        if types.include? :build
        include Create       if types.include? :create
        include DeleteSingle if types.include? :delete
        include FindSingle   if types.include? :find
        include Update       if types.include? :update
      end

      def url
        class_name.underscore
      end
    end

    def url
      self.class.url
    end

  end
end
