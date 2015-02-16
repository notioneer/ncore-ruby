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
          if params.empty?
            # only cache unfiltered, default api call
            @attribs[:#{assoc}] = (!reload && @attribs[:#{assoc}]) || #{klass}.all({#{key}: id}, api_creds)
          else
            #{klass}.all(params.merge(#{key}: id), api_creds)
          end
        end
      M1
      class_eval <<-M2, __FILE__, __LINE__+1
        def find_#{assoc.singularize}(aid, params={})
          raise UnsavedObjectError unless id
          #{klass}.find(aid, {#{key}: id}.reverse_merge(params), api_creds)
        end
      M2
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-M3, __FILE__, __LINE__+1
        def create_#{assoc.singularize}(params={})
          raise UnsavedObjectError unless id
          #{klass}.create(params.merge(#{key}: id), api_creds)
        end
      M3
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-M4, __FILE__, __LINE__+1
        def update_#{assoc.singularize}(aid, params={})
          obj = find_#{assoc.singularize}(aid)
          obj.update(params)
          obj
        end
      M4
      class_eval <<-M5, __FILE__, __LINE__+1
        def create_#{assoc.singularize}!(params={})
          raise UnsavedObjectError unless id
          #{klass}.create!(params.merge(#{key}: id), api_creds)
        end
      M5
      class_eval <<-M6, __FILE__, __LINE__+1
        def update_#{assoc.singularize}!(aid, params={})
          obj = find_#{assoc.singularize}(aid)
          obj.save!(params)
        end
      M6
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-M7, __FILE__, __LINE__+1
        def delete_#{assoc.singularize}(aid, params={})
          obj = find_#{assoc.singularize}(aid)
          obj.delete(params)
          obj
        end
      M7
      class_eval <<-M8, __FILE__, __LINE__+1
        def delete_#{assoc.singularize}!(aid, params={})
          raise UnsavedObjectError unless id
          #{klass}.delete!(aid, {#{key}: id}.reverse_merge(params), api_creds)
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
          if params.empty?
            # only cache unfiltered, default api call
            @attribs[:#{assoc}] ||= #{klass}.find(#{assoc}_id, {}, api_creds)
          else
            #{klass}.find(#{assoc}_id, params, api_creds)
          end
        end
      M1
      class_eval <<-M2, __FILE__, __LINE__+1
        def #{assoc}_id=(v)
          @attribs[:#{assoc}] = nil unless @attribs[:#{assoc}_id] == v
          @attribs[:#{assoc}_id] = v
        end
      M2
    end

  end
end
