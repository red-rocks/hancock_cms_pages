module Hancock::Pages
  module Models
    module ActiveRecord
      module Page
        extend ActiveSupport::Concern

        included do
          has_paper_trail
          validates_lengths_from_database only: [:name, :content_html, :excerpt_html, :regexp, :redirect, :fullpath]
          scope :sorted, -> { order(lft: :asc) }
          if Hancock::Pages.config.localize
            translates :name, :content_html, :excerpt_html
          end

          has_and_belongs_to_many :menus,
                                  class_name: "Hancock::Pages::Menu",
                                  join_table: :hancock_pages_menus_pages
        end
      end
    end
  end
end
