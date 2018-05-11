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

        # hancock_cms_hash_field :wrapper_attributes

        def render(view = Hancock::Pages::PagesController.new, content = "")
          if view.is_a?(Hash)
            view, content = view[:view] || Hancock::Pages::PagesController.new, view[:content]
          end
          # Hancock::Pages.config.renderer_lib_extends.each do |lib_extends|
          #   unless view.class < lib_extends
          #     if view.respond_to?(:prepend)
          #       view.prepend lib_extends
          #     else
          #       view.extend lib_extends
          #     end
          #   end
          # end

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

      end


      class_methods do
        def manager_can_add_actions
          ret = [:sort_embedded]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Pages.mongoid?
          ret << :model_settings if Hancock::Pages.config.model_settings_support
          # ret << :model_accesses if Hancock::Pages.config.user_abilities_support
          ret += [:comments, :model_comments] if Hancock::Pages.config.ra_comments_support
          ret.freeze
        end
        def rails_admin_add_visible_actions
          ret = [:sort_embedded]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Pages.mongoid?
          ret << :model_settings if Hancock::Pages.config.model_settings_support
          ret << :model_accesses if Hancock::Pages.config.user_abilities_support
          ret += [:comments, :model_comments] if Hancock::Pages.config.ra_comments_support
          ret.freeze
        end
      end

    end
  end
end
