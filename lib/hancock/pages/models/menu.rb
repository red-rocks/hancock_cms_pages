module Hancock::Pages
  module Models
    module Menu
      extend ActiveSupport::Concern
      include Hancock::Model
      include Hancock::Enableable
      include ManualSlug

      include Hancock::Pages.orm_specific('Menu')

      included do
        manual_slug :name

        after_save do
          Rails.cache.delete 'menus'
        end
        after_destroy do
          Rails.cache.delete 'menus'
        end
      end
    end
  end
end
