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

          has_many :blocks, class_name: "Hancock::Pages::Block", inverse_of: :blockset
          accepts_nested_attributes_for :blocks, allow_destroy: true

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
