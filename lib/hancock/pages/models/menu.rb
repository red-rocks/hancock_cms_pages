module Hancock::Pages
  module Models
    module Menu
      extend ActiveSupport::Concern
      include Hancock::Model
      include Hancock::Enableable
      include ManualSlug

      if Hancock::Pages.config.cache_support
        include Hancock::Cache::Cacheable
      end

      include Hancock::Pages.orm_specific('Menu')

      included do

        manual_slug :name

        def page_class
          self.class.page_class
        end
      end

      class_methods do
        if Hancock::Pages.config.cache_support
          def default_cache_keys
            ['menus']
          end
        end

        def page_class
          Hancock::Pages::Page
        end

        def manager_can_add_actions
          ret = []
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Pages.mongoid?
          ret << :model_settings if Hancock::Pages.config.model_settings_support
          # ret << :model_accesses if Hancock::Pages.config.user_abilities_support
          ret << :hancock_touch if Hancock::Pages.config.cache_support
          ret += [:comments, :model_comments] if Hancock::Pages.config.ra_comments_support
          ret.freeze
        end
        def rails_admin_add_visible_actions
          ret = []
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Pages.mongoid?
          ret << :model_settings if Hancock::Pages.config.model_settings_support
          ret << :model_accesses if Hancock::Pages.config.user_abilities_support
          ret << :hancock_touch if Hancock::Pages.config.cache_support
          ret += [:comments, :model_comments] if Hancock::Pages.config.ra_comments_support
          ret.freeze
        end
      end

    end
  end
end
