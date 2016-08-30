module Hancock::Pages
  module Models
    module Blockset
      extend ActiveSupport::Concern
      include Hancock::Model
      include Hancock::Enableable
      include ManualSlug

      include Hancock::Pages.orm_specific('Blockset')

      included do
        manual_slug :name


        def self.manager_can_add_actions
          [:sort_embedded]
        end
        def self.rails_admin_add_visible_actions
          [:sort_embedded]
        end
      end


      def render(view, content = "")
        ret = content
        if use_wrapper
          _attrs = {
            class: wrapper_class,
            id: wrapper_id
          }.merge(wrapper_attributes)
          ret = view.content_tag wrapper_tag, ret, _attrs
        end
        ret = yield ret if block_given?
        return ret
      end

      def wrapper_attributes=(val)
        if val.is_a? (String)
          begin
            begin
              self[:wrapper_attributes] = JSON.parse(val)
            rescue
              self[:wrapper_attributes] = YAML.load(val)
            end
          rescue
          end
        elsif val.is_a?(Hash)
          self[:wrapper_attributes] = val
        else
          self[:wrapper_attributes] = wrapper_attributes
        end
      end


    end
  end
end
