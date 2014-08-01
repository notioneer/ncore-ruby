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
          raise self.class.parent::Error, "Updating #{self.class.name} objects is not supported."
        end
      else
        if respond_to? :create, true
          create(update_params)
        else
          raise self.class.parent::Error, "Creating #{self.class.name} objects is not supported."
        end
      end
    end
    alias :update_attributes :save

    def save!(update_params={})
      save(update_params) || raise(self.class.parent::RecordInvalid, self)
    end
    alias :update_attributes! :save!

  end
end
