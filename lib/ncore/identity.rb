module NCore
  module Identity
    extend ActiveSupport::Concern

    module ClassMethods
      def class_name
        self.name.split('::')[-1]
      end

      def module_name
        self.name.split('::')[0..-2].join('::')
      end

      def attrib_name
        class_name.underscore
      end
      alias :json_root :attrib_name

      def i18n_scope
        module_parent::Api.i18n_scope
      end

      # make NCore::SomeResource.model_name do the right thing
      def model_name
        ::ActiveModel::Name.new(self, nil, ::ActiveSupport::Inflector.demodulize(self))
      end

    end


    # from ActiveRecord::Core
    def ==(comparison_object)
      super ||
        comparison_object.instance_of?(self.class) &&
        !id.nil? &&
        comparison_object.id == id
    end
    alias :eql? :==

    def hash
      if id
        self.class.hash ^ id.hash
      else
        super
      end
    end

    def json_root
      self.class.json_root
    end

  end
end
