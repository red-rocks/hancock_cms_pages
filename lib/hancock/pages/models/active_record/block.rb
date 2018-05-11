module Hancock::Pages
  module Models
    module ActiveRecord
      module Block
        extend ActiveSupport::Concern

        included do
          belongs_to :blockset, class_name: "Hancock::Pages::Blockset", inverse_of: :blocks

          hancock_cms_html_field :content

          acts_as_nested_set

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
