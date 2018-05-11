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
