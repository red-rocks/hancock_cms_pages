module Hancock::Pages
  module Models
    module Mongoid
      module Menu
        extend ActiveSupport::Concern

        included do
          index({enabled: 1, name: 1}, {background: true})

          has_and_belongs_to_many :pages, inverse_of: :menus, class_name: "Hancock::Pages::Page", index: true
          alias_method :items, :pages

          field :name, type: String, default: "", overwrite: true
        end
      end
    end
  end
end
