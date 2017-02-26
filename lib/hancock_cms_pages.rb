require "hancock/pages/version"
require 'hancock/pages/engine'
require 'hancock/pages/configuration'

require "hancock/pages/routes"

require 'hancock/pages/rails_admin_ext/hancock_connectable'
require 'hancock/pages/rails_admin_ext/menu'

require 'simple-navigation'

module Hancock::Pages
  include Hancock::Plugin

  autoload :Admin, 'hancock/pages/admin'
  module Admin
    autoload :Page, 'hancock/pages/admin/page'
    autoload :Menu, 'hancock/pages/admin/menu'
    autoload :Block, 'hancock/pages/admin/block'
    autoload :Blockset, 'hancock/pages/admin/blockset'
  end

  module Models
    autoload :Page, 'hancock/pages/models/page'
    autoload :Menu, 'hancock/pages/models/menu'
    autoload :Block, 'hancock/pages/models/block'
    autoload :Blockset, 'hancock/pages/models/blockset'

    module Mongoid
      autoload :Page, 'hancock/pages/models/mongoid/page'
      autoload :Menu, 'hancock/pages/models/mongoid/menu'
      autoload :Block, 'hancock/pages/models/mongoid/block'
      autoload :Blockset, 'hancock/pages/models/mongoid/blockset'
    end

    module ActiveRecord
      autoload :Page, 'hancock/pages/models/active_record/page'
      autoload :Menu, 'hancock/pages/models/active_record/menu'
      autoload :Block, 'hancock/pages/models/active_record/block'
      autoload :Blockset, 'hancock/pages/models/active_record/blockset'
    end
  end

  module Controllers
    autoload :Pages, 'hancock/pages/controllers/pages'
  end

end
