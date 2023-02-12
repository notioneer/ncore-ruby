module NCore
  module ActiveModel
    extend ActiveSupport::Concern

    included do
      include ::ActiveModel::Conversion
      extend  ::ActiveModel::Naming
      extend  ::ActiveModel::Translation
    end

    delegate :logger, to: :class

    def new_record?
      !id
    end

    def persisted?
      !new_record?
    end

    def destroy(*args)
      delete(*args)
    end


    # compatible with ActiveRecord 5.2+ default settings
    #   on <= 5.1, does not include version
    def cache_key(*_)
      if new_record?
        "#{model_name.cache_key}/new"
      else
        "#{model_name.cache_key}/#{id}"
      end
    end

    def cache_version
      if timestamp = try(:updated_at)
        timestamp.utc.to_s(:usec)
      end
    end

    def cache_key_with_version
      if version = cache_version
        "#{cache_key}-#{version}"
      else
        cache_key
      end
    end

  end
end
