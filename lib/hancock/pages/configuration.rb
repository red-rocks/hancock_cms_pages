module Hancock::Pages
  include Hancock::PluginConfiguration

  def self.config_class
    Configuration
  end

  class Configuration
    attr_accessor :menu_max_depth

    attr_accessor :seo_support
    attr_accessor :cache_support
    attr_accessor :insertions_support

    attr_accessor :localize

    attr_accessor :breadcrumbs_on_rails_support

    attr_accessor :model_settings_support
    attr_accessor :user_abilities_support
    attr_accessor :ra_comments_support

    attr_accessor :renderer_lib_extends

    attr_accessor :verbose_render
    attr_accessor :raven_support

    attr_accessor :available_layouts

    attr_accessor :standalone_paths

    def initialize
      @menu_max_depth = 2

      @seo_support        = !!defined? Hancock::Seo
      @cache_support      = !!defined?(Hancock::Cache)
      @insertions_support = true

      @localize   = Hancock.config.localize

      @breadcrumbs_on_rails_support = !!defined?(BreadcrumbsOnRails)

      @model_settings_support = !!defined?(RailsAdminModelSettings)
      @user_abilities_support = !!defined?(RailsAdminUserAbilities)
      @ra_comments_support = !!defined?(RailsAdminComments)

      @renderer_lib_extends = [
        # ::ActionController::Base,
        ::ActionView::Helpers::TagHelper,
        ::ActionView::Context
      ]

      @verbose_render = Rails.env.development? or Rails.env.test?
      @raven_support = !!(Hancock.config.respond_to?(:raven_support) ? Hancock.config.raven_support : defined?(Raven))

      @available_layouts = [nil, "application"]

      @standalone_paths = [['hancock', 'standalone']]

    end
  end
end
