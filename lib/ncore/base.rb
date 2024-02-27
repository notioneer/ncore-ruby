module NCore
  module Base
    extend ActiveSupport::Concern

    included do
      extend Associations
      include ActiveModel
      include Attributes
      include Client
      include Client::Cache
      include FilterAttributes
      include Identity
      include Lifecycle
      include Util
      include Wait

      self.filter_attributes = []
    end

    module ClassMethods
      def crud(*types)
        include All    if types.include? :all
        include Build  if types.include? :build
        include Count  if types.include? :count
        include Create if types.include? :create
        include Delete if types.include? :delete
        include DeleteBulk if types.include? :delete_bulk
        include Find   if types.include? :find
        include Update if types.include? :update
        include UpdateBulk if types.include? :update_bulk
      end

      def resource_path
        class_name.underscore.pluralize
      end
    end

    def resource_path
      "#{self.class.resource_path}/#{CGI.escape((id||'-').to_s)}"
    end

  end
end
