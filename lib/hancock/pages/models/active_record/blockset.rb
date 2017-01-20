module Hancock::Pages
  module Models
    module ActiveRecord
      module Blockset
        extend ActiveSupport::Concern

        included do
          has_paper_trail
          validates_lengths_from_database only: [:name]
          if Hancock::Pages.config.localize
            translates :name
          end

          has_many :blocks, class_name: "Hancock::Pages::Blockset", inverse_of: :blockset
          accepts_nested_attributes_for :blocks, allow_destroy: true
        end
      end
    end
  end
end
