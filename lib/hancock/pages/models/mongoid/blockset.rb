module Hancock::Pages
  module Models
    module Mongoid
      module Blockset
        extend ActiveSupport::Concern

        included do
          index({enabled: 1, name: 1}, {background: true})

          field :name, type: String, default: "", overwrite: true

          embeds_many :blocks, inverse_of: :blockset, class_name: "Hancock::Pages::Block", order: [:order, :asc]
          accepts_nested_attributes_for :blocks, allow_destroy: true

          field :use_wrapper, type: Boolean, default: false
          field :wrapper_tag, type: String, default: ""
          field :wrapper_class, type: String, default: ""
          field :wrapper_id, type: String, default: ""
          field :wrapper_attributes, type: Hash, default: {}
        end

      end
    end
  end
end
