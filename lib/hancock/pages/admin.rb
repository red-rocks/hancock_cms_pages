module Hancock::Pages
  module Admin

    def self.menu_block(is_active = false)
      Proc.new {
        active false
        label I18n.t('hancock.menu_title')
        field :menus do
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

        if block_given?
          yield self
        end
      }
    end

    def self.wrapper_block(is_active = false)
      Proc.new {
        active is_active
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

        if block_given?
          yield self
        end
      }
    end
  end
end
