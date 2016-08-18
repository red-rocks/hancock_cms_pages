module Hancock::Pages
  module Models
    module ActiveRecord
      module Block
        extend ActiveSupport::Concern

        # include Hancock::HtmlField

        included do
          belongs_to :blockset, class_name: "Hancock::Pages::Block"
        end

      end
    end
  end
end
