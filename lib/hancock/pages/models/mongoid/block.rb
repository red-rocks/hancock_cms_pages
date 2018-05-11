module Hancock::Pages
  module Models
    module Mongoid
      module Block
        extend ActiveSupport::Concern

        included do
          field :name, type: String, default: "", overwrite: true

          field :pageblock_selector, type: String, localize: Hancock::Pages.config.localize, default: ""
          field :file_path, type: String, localize: Hancock::Pages.config.localize, default: ""
          field :partial, type: Boolean, default: true
          field :render_file, type: Boolean, default: true
          embedded_in :blockset, inverse_of: :blocks, class_name: "Hancock::Pages::Blockset"

          validates_inclusion_of :file_path, in: proc {
            # Settings.hancock_pages_blocks_whitelist.lines.map(&:strip).compact
            # Hancock::Pages.views_whitelist_as_array.compact
            (Hancock::Pages.views_whitelist_as_array - Hancock::Pages.views_blacklist_as_array).compact
          }, allow_blank: true
          # validates_inclusion_of :file_path, in: proc {
          #   Hancock::Pages::Blockset.settings.blocks_whitelist.lines.map(&:strip).compact
          # }, allow_blank: true

          def self.find(id)
            find_through(Hancock::Pages::Blockset, 'blocks', id)
          end

          def get_fullpath
            self.pageblock_selector.blank? ? "#" : self.pageblock_selector
          end

          hancock_cms_html_field :content, type: String, localize: Hancock::Pages.config.localize, default: ""

          field :use_wrapper, type: Boolean, default: false
          field :wrapper_tag, type: String, default: ""
          field :wrapper_class, type: String, default: ""
          field :wrapper_id, type: String, default: ""

          field :menu_link_content, type: String
          field :show_in_menu, type: Boolean, default: true

          field :wrapper_attributes, type: Hash, default: {}
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
          def wrapper_attributes_str
            self[:wrapper_attributes] ||= self.wrapper_attributes.to_json if self.wrapper_attributes
          end
        end

      end
    end
  end
end
