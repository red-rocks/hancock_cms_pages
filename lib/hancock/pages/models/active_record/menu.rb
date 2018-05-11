module Hancock::Pages
  module Models
    module ActiveRecord
      module Menu
        extend ActiveSupport::Concern

        included do
          has_paper_trail
          validates_lengths_from_database only: [:name]
          if Hancock::Pages.config.localize
            translates :name
          end

          has_and_belongs_to_many :pages,
                                  class_name: "Hancock::Pages::Page",
                                  join_table: :hancock_pages_menu_pages,
                                  foreign_key: :hancock_pages_menu_id,
                                  association_foreign_key: :hancock_pages_page_id

          attr_accessor :enabled, :name, :slug

        end
        
      end
    end
  end
end
