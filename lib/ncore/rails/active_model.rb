require 'active_model'

module NCore
  module ActiveModel
    extend ActiveSupport::Concern

    included do
      include ::ActiveModel::Conversion
      extend  ::ActiveModel::Naming
      extend  ::ActiveModel::Translation
      alias :errors :errors_for_actionpack
    end

    if defined?(Rails)
      def logger
        Rails.logger
      end
    end

    def new_record?
      !id
    end

    def persisted?
      !new_record?
    end

    def destroy(*args)
      delete(*args)
    end

    # actionpack 4 requires a more robust Errors object
    def errors_for_actionpack
      e0 = ::ActiveModel::Errors.new(self)
      @errors.each do |e|
        e0.add :base, e
      end
      e0
    end

  end

  Base.send :include, ActiveModel
  SingletonBase.send :include, ActiveModel
end
