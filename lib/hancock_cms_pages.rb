unless defined?(Hancock) && Hancock.respond_to?(:orm) && [:active_record, :mongoid].include?(Hancock.orm)
  puts "please use hancock_cms_mongoid or hancock_cms_activerecord"
  puts "also: please use hancock_cms_news_mongoid or hancock_cms_news_activerecord and not hancock_cms_news directly"
  exit 1
end

require "hancock/pages/version"
require 'hancock/pages/engine'
require 'hancock/pages/configuration'

require "hancock/pages/routes"

require 'hancock/pages/rails_admin_ext/hancock_connectable'
require 'hancock/pages/rails_admin_ext/menu'

require 'simple-navigation'

module Hancock::Pages
  # Hancock::register_plugin(self)

  class << self
    def orm
      Hancock.orm
    end
    def mongoid?
      Hancock::Pages.orm == :mongoid
    end
    def active_record?
      Hancock::Pages.orm == :active_record
    end
    def model_namespace
      "Hancock::Pages::Models::#{Hancock::Pages.orm.to_s.camelize}"
    end
    def orm_specific(name)
      "#{model_namespace}::#{name}".constantize
    end
  end

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
