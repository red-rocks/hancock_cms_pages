module Hancock::Pages
  if Hancock::Pages.active_record?
    class Page < ActiveRecord::Base
    end
  end

  class Page
    include Hancock::Pages::Models::Page

    include Hancock::Pages::Decorators::Page

    rails_admin(&Hancock::Pages::Admin::Page.config(rails_admin_add_fields) { |config|
      rails_admin_add_config(config)
    })
  end
end
