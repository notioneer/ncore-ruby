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
    end


    def json_root
      self.class.json_root
    end

  end
end
