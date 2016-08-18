module Hancock::Pages
  if Hancock::Pages.mongoid?
    class Block < Hancock::EmbeddedElement
      include Hancock::Pages::Models::Block

      include Hancock::Pages::Decorators::Block

      rails_admin(&Hancock::Pages::Admin::Block.config(rails_admin_add_fields) { |config|
        rails_admin_add_config(config)
      })
    end
  end
end
