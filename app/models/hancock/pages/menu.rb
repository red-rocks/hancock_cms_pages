module Hancock::Pages
  if Hancock::Pages.active_record?
    class Menu < ApplicationRecord
      self.table_name = "hancock_pages_menus".freeze
    end
  end

  class Menu
    include Hancock::Pages::Models::Menu

    include Hancock::Pages::Decorators::Menu

    rails_admin(&Hancock::Pages::Admin::Menu.config(rails_admin_add_fields) { |config|
      rails_admin_add_config(config)
    })
  end
end
