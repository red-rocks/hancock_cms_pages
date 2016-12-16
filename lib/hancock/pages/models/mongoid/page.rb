module Hancock::Pages
  module Models
    module Mongoid
      module Page
        extend ActiveSupport::Concern

        include Hancock::HtmlField

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

          field :regexp, type: String, default: ""
          field :redirect, type: String, default: ""
          hancock_cms_html_field :excerpt, type: String, localize: Hancock::Pages.config.localize, default: ""
          hancock_cms_html_field :content, type: String, localize: Hancock::Pages.config.localize, default: ""
          field :fullpath, type: String, default: ""

          has_and_belongs_to_many :menus, inverse_of: :pages, class_name: "Hancock::Pages::Menu", index: true

          scope :sorted, -> { order_by([:lft, :asc]) }
          scope :menu, ->(menu_id) { enabled.sorted.where(menu_ids: menu_id) }
        end
      end
    end
  end
end
