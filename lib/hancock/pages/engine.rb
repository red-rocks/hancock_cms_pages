module Hancock::Pages
  class Engine < ::Rails::Engine
    # isolate_namespace Hancock::Pages

    # initializer "hancock_cms_pages.blocksets_settings" do
    #   # Write default email settings to DB so they can be changed.
    #
    #   #temp
    #   begin
    #     if Settings and Settings.table_exists?
    #       Settings.hancock_pages_blocks_whitelist(default: '', kind: :text, label: 'Белый список блоков')
    #       Settings.hancock_pages_blocks_human_names(default: '', kind: :yaml, label: 'Имена блоков')
    #     end
    #
    #     # if Settings and Settings.table_exists? and Hancock::Pages.model_settings_support
    #     #   Hancock::Pages::Blockset.settings.blocks_whitelist(default: '', kind: :text, label: 'Белый список блоков')
    #     #   Hancock::Pages::Blockset.settings.blocks_human_names(default: '', kind: :yaml, label: 'Имена блоков')
    #     #
    #     #
    #     #   _setting_existed = !Hancock::Cache::Fragment.settings.getnc('detecting').nil?
    #     #   unless _setting_existed
    #     #     Hancock::Pages::Blockset.settings.blocks_whitelist(kind: :text, default: '', label: 'Белый список блоков')
    #     #     Hancock::Pages::Blockset.settings.unload!
    #     #     _setting = Hancock::Pages::Blockset.settings.getnc('blocks_whitelist')
    #     #     if _setting
    #     #       _setting.for_admin = true
    #     #       _setting.perform_caching = false
    #     #       _setting.save
    #     #     end
    #     #   end
    #     #
    #     #
    #     #   _setting_existed = !Hancock::Cache::Fragment.settings.getnc('detecting').nil?
    #     #   unless _setting_existed
    #     #     Hancock::Pages::Blockset.settings.blocks_human_names(default: '', kind: :yaml, label: 'Имена блоков')
    #     #     Hancock::Pages::Blockset.settings.unload!
    #     #     _setting = Hancock::Pages::Blockset.settings.getnc('blocks_human_names')
    #     #     if _setting
    #     #       _setting.for_admin = true
    #     #       _setting.perform_caching = false
    #     #       _setting.save
    #     #     end
    #     #   end
    #     #
    #     # end
    #   rescue
    #   end
    # end

    config.after_initialize do
      # Write default email settings to DB so they can be changed.
      begin
        if Settings and Settings.table_exists?
          # Settings.hancock_pages_blocks_whitelist(default: '', kind: :text, label: 'Белый список блоков') unless RailsAdminSettings::Setting.ns("main").where(key: "hancock_pages_blocks_whitelist").exists?
          # Settings.hancock_pages_blocks_human_names(default: '', kind: :yaml, label: 'Имена блоков') unless RailsAdminSettings::Setting.ns("main").where(key: "hancock_pages_blocks_human_names").exists?

          # Settings.ns('admin').hancock_pages_blocks_blacklist(default: '', kind: :text, label: 'Черный список блоков') unless RailsAdminSettings::Setting.ns("admin").where(key: "hancock_pages_blocks_blacklist").exists?


          unless Settings.rename(:hancock_pages_blocks_whitelist, :hancock_pages_blocks_views_whitelist)
            Settings.hancock_pages_blocks_views_whitelist(default: '', kind: :text, label: 'Белый список блоков') unless Settings.exists?("hancock_pages_blocks_views_whitelist")
          end
          unless Settings.rename(:hancock_pages_blocks_human_names, :hancock_pages_blocks_views_human_names)
            Settings.hancock_pages_blocks_views_human_names(default: '', kind: :yaml, label: 'Имена блоков') unless Settings.exists?("hancock_pages_blocks_views_human_names")
          end
          unless Settings.ns('admin').rename(:hancock_pages_blocks_blacklist, :hancock_pages_blocks_views_blacklist)
            Settings.ns('admin').hancock_pages_blocks_views_blacklist(default: '', kind: :text, label: 'Черный список блоков') unless Settings.ns('admin').exists?("hancock_pages_blocks_views_blacklist")
          end

          Settings.ns('admin').helpers_whitelist(default: '', kind: :text, label: 'Белый список хелперов') unless Settings.ns('admin').exists?("helpers_whitelist")
          Settings.ns('admin').helpers_human_names(default: '', kind: :yaml, label: 'Имена хелперов') unless Settings.ns('admin').exists?("helpers_human_names")

        end
      rescue
      end
    end

  end
end
