module Hancock::Pages
  if Hancock::Pages.active_record?
    class Block < ApplicationRecord
      self.table_name = "hancock_pages_blocks".freeze
    end
  elsif Hancock::Pages.mongoid?
    class Block < Hancock::EmbeddedElement
    end
  end

  class Block
    include Hancock::Pages::Models::Block

    include Hancock::Pages::Decorators::Block

    rails_admin(&Hancock::Pages::Admin::Block.config(rails_admin_add_fields) { |config|
      rails_admin_add_config(config)
    })

  end
end
