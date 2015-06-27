module NCore
  module Associations

    def has_many(assoc, klass=nil)
      assoc = assoc.to_s
      klass ||= "#{module_name}::#{assoc.camelize.singularize}"
      key = "#{attrib_name}_id"
      class_eval <<-M1, __FILE__, __LINE__+1
        def #{assoc}(params={})
          return [] unless id
          reload = params.delete :reload
          params = parse_request_params(params).reverse_merge credentials: api_creds
          cacheable = params.except(:credentials, :request).empty?
          params.merge! #{key}: id
          if cacheable
            # only cache unfiltered, default api call
            @attribs[:#{assoc}] = (!reload && @attribs[:#{assoc}]) || #{klass}.all(params)
          else
            #{klass}.all(params)
          end
        end
      M1
      class_eval <<-M2, __FILE__, __LINE__+1
        def find_#{assoc.singularize}(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params.merge! #{key}: id
          #{klass}.find(aid, params)
        end
      M2
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-M3, __FILE__, __LINE__+1
        def create_#{assoc.singularize}(params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params.merge! #{key}: id
          #{klass}.create(params)
        end
      M3
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-M4, __FILE__, __LINE__+1
        def update_#{assoc.singularize}(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params.merge! #{key}: id
          #{klass}.update(aid, params)
        end
      M4
      class_eval <<-M5, __FILE__, __LINE__+1
        def create_#{assoc.singularize}!(params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params.merge! #{key}: id
          #{klass}.create!(params)
        end
      M5
      class_eval <<-M6, __FILE__, __LINE__+1
        def update_#{assoc.singularize}!(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params.merge! #{key}: id
          #{klass}.update!(aid, params)
        end
      M6
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-M7, __FILE__, __LINE__+1
        def delete_#{assoc.singularize}(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params.merge! #{key}: id
          #{klass}.delete(aid, params)
        end
      M7
      class_eval <<-M8, __FILE__, __LINE__+1
        def delete_#{assoc.singularize}!(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params.merge! #{key}: id
          #{klass}.delete!(aid, params)
        end
      M8
    end

    def belongs_to(assoc, klass=nil)
      assoc = assoc.to_s
      klass ||= "#{module_name}::#{assoc.camelize}"
      class_eval <<-M1, __FILE__, __LINE__+1
        attr :#{assoc}_id
        def #{assoc}(params={})
          return nil unless #{assoc}_id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          if params.except(:credentials, :request).empty?
            # only cache unfiltered, default api call
            @attribs[:#{assoc}] ||= #{klass}.find(#{assoc}_id, params)
          else
            #{klass}.find(#{assoc}_id, params)
          end
        end
      M1
      class_eval <<-M2, __FILE__, __LINE__+1
        def #{assoc}_id=(v)
          @attribs[:#{assoc}] = nil unless @attribs[:#{assoc}_id] == v
          @attribs[:#{assoc}_id] = v
        end
        private :#{assoc}_id=
      M2
    end

  end
end
