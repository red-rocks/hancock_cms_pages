module Hancock::Pages
  class Engine < ::Rails::Engine
    # isolate_namespace Hancock::Pages

    initializer "hancock_cms_pages.blocksets_settings" do
      # Write default email settings to DB so they can be changed.

      #temp
      begin
        if Settings and Settings.table_exists?
          Settings.hancock_pages_blocks_whitelist(default: '', kind: :text, label: 'Белый список блоков')
          Settings.hancock_pages_blocks_human_names(default: '', kind: :yaml, label: 'Имена блоков')
        end

        # if Settings and Settings.table_exists?
        #   Hancock::Pages::Blockset.settings.blocks_whitelist(default: '', kind: :text, label: 'Белый список блоков')
        #   Hancock::Pages::Blockset.settings.blocks_human_names(default: '', kind: :yaml, label: 'Имена блоков')
        #
        #
        #   _setting_existed = !Hancock::Cache::Fragment.settings.getnc('detecting').nil?
        #   unless _setting_existed
        #     Hancock::Pages::Blockset.settings.blocks_whitelist(kind: :text, default: '', label: 'Белый список блоков')
        #     Hancock::Pages::Blockset.settings.unload!
        #     _setting = Hancock::Pages::Blockset.settings.getnc('blocks_whitelist')
        #     if _setting
        #       _setting.for_admin = true
        #       _setting.perform_caching = false
        #       _setting.save
        #     end
        #   end
        #
        #
        #   _setting_existed = !Hancock::Cache::Fragment.settings.getnc('detecting').nil?
        #   unless _setting_existed
        #     Hancock::Pages::Blockset.settings.blocks_human_names(default: '', kind: :yaml, label: 'Имена блоков')
        #     Hancock::Pages::Blockset.settings.unload!
        #     _setting = Hancock::Pages::Blockset.settings.getnc('blocks_human_names')
        #     if _setting
        #       _setting.for_admin = true
        #       _setting.perform_caching = false
        #       _setting.save
        #     end
        #   end
        #
        # end
      rescue
      end
    end

  end
end
