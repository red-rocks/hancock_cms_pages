module Hancock::Pages
  module Admin

    def self.menu_block(is_active = false)
      Proc.new {
        active false
        label I18n.t('hancock.menu_title')
        field :menus
        field :fullpath, :string do
          help I18n.t('hancock.with_final_slash')
        end
        field :regexp, :string do
          help I18n.t('hancock.page_url_regex')
        end
        field :redirect, :string do
          help I18n.t('hancock.final_in_menu')
        end
        field :text_slug

        if block_given?
          yield self
        end
      }
    end

    def self.wrapper_block(is_active = false)
      Proc.new {
        active is_active
        field :use_wrapper, :toggle
        field :wrapper_tag, :string
        field :wrapper_class, :string
        field :wrapper_id, :string
        field :wrapper_attributes, :text do
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
