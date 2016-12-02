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
      rescue
      end
    end

  end
end
