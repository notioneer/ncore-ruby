module NCore
  module Base
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
        include All    if types.include? :all
        include Build  if types.include? :build
        include Count  if types.include? :count
        include Create if types.include? :create
        include Delete if types.include? :delete
        include Find   if types.include? :find
        include Update if types.include? :update
      end

      def url
        class_name.underscore.pluralize
      end
    end

    def url
      "#{self.class.url}/#{CGI.escape((id||'-').to_s)}"
    end

  end
end
