module Hancock::Pages
  module Models
    module Mongoid
      module Block
        extend ActiveSupport::Concern

        include Hancock::HtmlField

        included do
          field :name, type: String, default: ""

          field :pageblock_selector, type: String, localize: Hancock::Pages.config.localize, default: ""
          field :file_path, type: String, localize: Hancock::Pages.config.localize, default: ""
          field :partial, type: Boolean, default: true
          embedded_in :blockset, inverse_of: :blocks, class_name: "Hancock::Pages::Blockset"

          hancock_cms_html_field :content, type: String, localize: Hancock::Pages.config.localize, default: ""

          field :use_wrapper, type: Boolean, default: false
          field :wrapper_tag, type: String, default: ""
          field :wrapper_class, type: String, default: ""
          field :wrapper_id, type: String, default: ""
          field :wrapper_attributes, type: Hash, default: {}

          field :menu_link_content, type: String
          field :show_in_menu, type: Boolean, default: true
          scope :show_in_menu, -> { where(show_in_menu: true) }
        end

      end
    end
  end
end
