module Hancock::Pages
  include Hancock::PluginConfiguration

  def self.config_class
    Configuration
  end
  
  class Configuration
    attr_accessor :menu_max_depth

    attr_accessor :seo_support

    attr_accessor :localize

    attr_accessor :breadcrumbs_on_rails_support

    def initialize
      @menu_max_depth = 2

      @seo_support = defined? Hancock::Seo

      @localize   = Hancock.config.localize

      @breadcrumbs_on_rails_support = defined?(BreadcrumbsOnRails)
    end
  end
end
