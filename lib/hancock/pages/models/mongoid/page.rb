module Hancock::Pages
  module Models
    module Mongoid
      module Page
        extend ActiveSupport::Concern

        included do
          index({enabled: 1, lft: 1, menu_ids: 1}, {background: true})
          index({parent_id: 1}, {background: true})
          index({hancock_connectable_id: 1, hancock_connectable_type: 1}, {background: true})
          index({enabled: 1, fullpath: 1}, {background: true})

          scope :connected, -> {
            where(:hancock_connectable_id.ne => nil)
          }
          scope :unconnected, -> (except_this = nil) {
            if except_this
              where({"$or" =>[
                {:hancock_connectable_id => nil},
                {"$and" => [
                  {hancock_connectable_type: except_this.class.to_param},
                  {hancock_connectable_id: except_this._id}
                ]}
              ]})
            else
              where(:hancock_connectable_id => nil)
            end
          }

          field :name, type: String, localize: Hancock::Pages.config.localize, default: ""
          field :layout_name, type: String, default: "application"

          field :regexp, type: String, default: ""
          field :redirect, type: String, default: ""
          hancock_cms_html_field :excerpt, type: String, localize: Hancock::Pages.config.localize, default: ""
          hancock_cms_html_field :content, type: String, localize: Hancock::Pages.config.localize, default: ""
          field :fullpath, type: String, default: ""

          field :use_wrapper, type: Boolean, default: false
          field :wrapper_tag, type: String, default: ""
          field :wrapper_class, type: String, default: ""
          field :wrapper_id, type: String, default: ""

          has_and_belongs_to_many :menus, inverse_of: :pages, class_name: "Hancock::Pages::Menu", index: true

          scope :menu, ->(menu_id) { enabled.sorted.where(menu_ids: menu_id) }

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
