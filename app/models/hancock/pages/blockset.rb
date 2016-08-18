module Hancock::Pages
  if Hancock::Pages.mongoid?
    class Blockset
      include Hancock::Pages::Models::Blockset

      include Hancock::Pages::Decorators::Blockset

      rails_admin(&Hancock::Pages::Admin::Blockset.config(rails_admin_add_fields) { |config|
        rails_admin_add_config(config)
      })
    end
  end
end
