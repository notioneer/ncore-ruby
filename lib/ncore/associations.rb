module NCore
  module Associations

    # assoc_name       - singular association name
    # :association_key - key used by the association to reference the parent
    #                    defaults to `attrib_name+'_id'`
    # :class_name      - Module::Class of the child association, as a string
    def has_one(assoc_name, association_key: nil, class_name: nil)
      assoc_name = assoc_name.to_s
      parent_key = association_key&.to_s || "#{attrib_name}_id"
      klass      = class_name || "#{module_name}::#{assoc_name.camelize}"

      # def item({})
      class_eval <<-A1, __FILE__, __LINE__+1
        def #{assoc_name}(params={})
          return nil unless id
          reload = params.delete :reload
          cacheable = params.except(:credentials, :request).empty?
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          if cacheable
            # only cache unfiltered, default api call
            @attribs[:#{assoc_name}] = (!reload && @attribs[:#{assoc_name}]) || #{klass}.first(params)
          else
            #{klass}.first(params)
          end
        end
      A1

      # def create_item({})
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-C1, __FILE__, __LINE__+1
        def create_#{assoc_name}(params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          #{klass}.create(params)
        end
      C1

      # def create_item!({})
      class_eval <<-C2, __FILE__, __LINE__+1
        def create_#{assoc_name}!(params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          #{klass}.create!(params)
        end
      C2

      # def update_item({})
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-U1, __FILE__, __LINE__+1
        def update_#{assoc_name}(params={})
          raise UnsavedObjectError unless id
          #{assoc_name}.update(params)
        end
      U1

      # def update_item!({})
      class_eval <<-U2, __FILE__, __LINE__+1
        def update_#{assoc_name}!(params={})
          raise UnsavedObjectError unless id
          #{assoc_name}.update!(params)
        end
      U2

      # def delete_item({})
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-D1, __FILE__, __LINE__+1
        def delete_#{assoc_name}(params={})
          raise UnsavedObjectError unless id
          #{assoc_name}.delete(params)
        end
      D1

      # def delete_item!({})
      class_eval <<-D2, __FILE__, __LINE__+1
        def delete_#{assoc_name}!(params={})
          raise UnsavedObjectError unless id
          #{assoc_name}.delete!(params)
        end
      D2
    end


    # assoc_name       - plural association name
    # :association_key - key used by the association to reference the parent
    #                    defaults to `attrib_name+'_id'`
    # :class_name      - Module::Class of the child association, as a string
    def has_many(assoc_name, association_key: nil, class_name: nil)
      assoc_name = assoc_name.to_s
      parent_key = association_key&.to_s || "#{attrib_name}_id"
      klass      = class_name || "#{module_name}::#{assoc_name.camelize.singularize}"

      # def items({})
      class_eval <<-A1, __FILE__, __LINE__+1
        def #{assoc_name}(params={})
          return [] unless id
          reload = params.delete :reload
          cacheable = params.except(:credentials, :request).empty?
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          if cacheable
            # only cache unfiltered, default api call
            @attribs[:#{assoc_name}] = (!reload && @attribs[:#{assoc_name}]) || #{klass}.all(params)
          else
            #{klass}.all(params)
          end
        end
      A1

      # def find_item(id, {})
      class_eval <<-F1, __FILE__, __LINE__+1
        def find_#{assoc_name.singularize}(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          #{klass}.find(aid, params)
        end
      F1

      # def retrieve_item(id, {})
      class_eval <<-F2, __FILE__, __LINE__+1
        def retrieve_#{assoc_name.singularize}(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          #{klass}.retrieve(aid, params)
        end
      F2

      # def create_item({})
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-C1, __FILE__, __LINE__+1
        def create_#{assoc_name.singularize}(params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          #{klass}.create(params)
        end
      C1

      # def create_item!({})
      class_eval <<-C2, __FILE__, __LINE__+1
        def create_#{assoc_name.singularize}!(params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          #{klass}.create!(params)
        end
      C2

      # def update_item(id, {})
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-U1, __FILE__, __LINE__+1
        def update_#{assoc_name.singularize}(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          #{klass}.update(aid, params)
        end
      U1

      # def update_item!(id, {})
      class_eval <<-U2, __FILE__, __LINE__+1
        def update_#{assoc_name.singularize}!(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          #{klass}.update!(aid, params)
        end
      U2

      # def delete_item(id, {})
      # will always return the object; check .errors? or .valid? to see how it went
      class_eval <<-D1, __FILE__, __LINE__+1
        def delete_#{assoc_name.singularize}(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          #{klass}.delete(aid, params)
        end
      D1

      # def delete_item!(id, {})
      class_eval <<-D2, __FILE__, __LINE__+1
        def delete_#{assoc_name.singularize}!(aid, params={})
          raise UnsavedObjectError unless id
          params = parse_request_params(params).reverse_merge credentials: api_creds
          params[:#{parent_key}] = id
          #{klass}.delete!(aid, params)
        end
      D2
    end


    # assoc_name       - singular association name
    # :association_key - key on this resource used to reference the parent association
    #                    defaults to `assoc_name+'_id'`
    # :class_name      - Module::Class of the parent association, as a string
    def belongs_to(assoc_name, association_key: nil, class_name: nil)
      assoc_name = assoc_name.to_s
      parent_key = association_key&.to_s || "#{assoc_name}_id"
      klass      = class_name || "#{module_name}::#{assoc_name.camelize}"

      # attr :parent_id
      # def parent({})
      class_eval <<-P1, __FILE__, __LINE__+1
        attr :#{parent_key}
        def #{assoc_name}(params={})
          reload = params.delete :reload
          params = parse_request_params(params).reverse_merge credentials: api_creds
          if params.except(:credentials, :request).empty?
            # only cache unfiltered, default api call
            @attribs[:#{assoc_name}] = nil if reload
            @attribs[:#{assoc_name}] ||= #{parent_key} && #{klass}.find(#{parent_key}, params)
          else
            return nil unless #{parent_key}
            #{klass}.find(#{parent_key}, params)
          end
        end
      P1

      # private def parent_id=(val)
      # if :parent_key changes, clear memoized association
      class_eval <<-P2, __FILE__, __LINE__+1
        def #{parent_key}=(v)
          if @attribs[:#{parent_key}] != v and @attribs[:#{assoc_name}]&.id != v
            @attribs[:#{assoc_name}] = nil
          end
          @attribs[:#{parent_key}] = v
        end
        private :#{parent_key}=
      P2
    end

  end
end
