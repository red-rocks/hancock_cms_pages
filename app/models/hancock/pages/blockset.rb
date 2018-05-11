module Hancock::Pages
  if Hancock::Pages.active_record?
    class Blockset < ApplicationRecord
      self.table_name = "hancock_pages_blocksets".freeze
    end
  end

  class Blockset
    include Hancock::Pages::Models::Blockset

    include Hancock::Pages::Decorators::Blockset

    rails_admin(&Hancock::Pages::Admin::Blockset.config(rails_admin_add_fields) { |config|
      rails_admin_add_config(config)
    })
    
  end
end
