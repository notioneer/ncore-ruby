module NCore
  module Lifecycle

    def errors?
      @errors.any?
    end

    def valid?
      @errors.none?
    end


    def save(update_params={})
      if id.present?
        if respond_to? :update, true
          update(update_params)
        else
          raise self.class.module_parent::Error, "Updating #{self.class.name} objects is not supported."
        end
      else
        if respond_to? :create, true
          create(update_params)
        else
          raise self.class.module_parent::Error, "Creating #{self.class.name} objects is not supported."
        end
      end
    end
    alias :update_attributes :save

    def save!(update_params={})
      save(update_params) || raise(self.class.module_parent::RecordInvalid, self)
    end
    alias :update_attributes! :save!

  end
end
