module Hancock::Pages
  module Models
    module ActiveRecord
      module Page
        extend ActiveSupport::Concern

        included do

          scope :connected, -> {
            where('`hancock_connectable_id` IS NOT NULL')
          }
          scope :unconnected, -> (except_this = nil) {
            if except_this
              where('`hancock_connectable_id` IS NULL OR (`hancock_connectable_type` = ? AND `hancock_connectable_id` = ?)',
                except_this.class.to_param,
                except_this.id
              )
            else
              where('`hancock_connectable_id` IS NULL')
            end
          }

          hancock_cms_html_field :excerpt
          hancock_cms_html_field :content

          has_paper_trail
          validates_lengths_from_database only: [:name, :content_html, :excerpt_html, :regexp, :redirect, :fullpath]

          if Hancock::Pages.config.localize
            translates :name, :content_html, :excerpt_html
          end

          has_and_belongs_to_many :menus,
                                  class_name: "Hancock::Pages::Menu",
                                  join_table: :hancock_pages_menu_pages,
                                  foreign_key: :hancock_pages_page_id,
                                  association_foreign_key: :hancock_pages_menu_id

          scope :menu, ->(menu_id) { enabled.sorted.joins(:menus).where(hancock_pages_menus: {id: menu_id}) }

          def wrapper_attributes
            JSON.parse(self[:wrapper_attributes]) rescue {}
          end
          def wrapper_attributes=(val)
            self[:wrapper_attributes] = (val and val.to_json) || {} rescue {}
          end
        end

      end
    end
  end
end
