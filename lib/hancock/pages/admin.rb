module Hancock::Pages
  module Admin

    def self.menu_block(is_active = false, options = {})
      if is_active.is_a?(Hash)
        is_active, options = (is_active[:active] || false), is_active
      end

      Proc.new {
        active false
        label options[:label] || I18n.t('hancock.menu_title')
        field :menus, :hancock_multiselect do
          searchable :name, :text_slug
        end
        field :fullpath, :string do
          help I18n.t('hancock.with_final_slash')
          searchable true
        end
        field :regexp, :string do
          help I18n.t('hancock.page_url_regex')
          searchable true
        end
        field :redirect, :string do
          help I18n.t('hancock.final_in_menu')
          searchable true
        end
        field :text_slug do
          searchable true
        end

        Hancock::RailsAdminGroupPatch::hancock_cms_group(self, options[:fields] || {})

        if block_given?
          yield self
        end
      }
    end

    def self.wrapper_block(is_active = false, options = {})
      if is_active.is_a?(Hash)
        is_active, options = (is_active[:active] || false), is_active
      end

      Proc.new {
        active is_active
        options[:label] and label(options[:label])
        field :use_wrapper, :toggle
        field :wrapper_tag, :string do
          searchable true
        end
        field :wrapper_class, :string do
          searchable true
        end
        field :wrapper_id, :string do
          searchable true
        end
        field :wrapper_attributes, :text do
          searchable true
          formatted_value do
            bindings[:object] and bindings[:object].wrapper_attributes ? bindings[:object].wrapper_attributes.to_json : "{}"
          end
        end

        Hancock::RailsAdminGroupPatch::hancock_cms_group(self, options[:fields] || {})

        if block_given?
          yield self
        end
      }
    end
  end
end
