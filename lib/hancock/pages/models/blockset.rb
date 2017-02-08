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
          ret = [:sort_embedded]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Pages.mongoid?
          ret << :model_settings if Hancock::Pages.config.model_settings_support
          # ret << :model_accesses if Hancock::Pages.config.user_abilities_support
          ret += [:comments, :model_comments] if Hancock::Pages.config.ra_comments_support
          ret.freeze
        end
        def self.rails_admin_add_visible_actions
          ret = [:sort_embedded]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Pages.mongoid?
          ret << :model_settings if Hancock::Pages.config.model_settings_support
          ret << :model_accesses if Hancock::Pages.config.user_abilities_support
          ret += [:comments, :model_comments] if Hancock::Pages.config.ra_comments_support
          ret.freeze
        end
      end


      def render(view = Hancock::Pages::PagesController.new, content = "")
        if view.is_a?(Hash)
          view, content = view[:view] || Hancock::Pages::PagesController.new, view[:content]
        end
        [::ActionView::Helpers::TagHelper, ::ActionView::Context].each do |lib_extends|
          view.prepend lib_extends unless view.class < lib_extends
        end

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
