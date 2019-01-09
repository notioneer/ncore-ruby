module NCore
  module ActiveModel
    extend ActiveSupport::Concern

    included do
      include ::ActiveModel::Conversion
      extend  ::ActiveModel::Naming
      extend  ::ActiveModel::Translation
    end

    if defined?(::Rails)
      def logger
        ::Rails.logger
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


  end
end
