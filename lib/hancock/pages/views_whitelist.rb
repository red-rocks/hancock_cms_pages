module Hancock::Pages::ViewsWhitelist

  def self.included(base)

    class << base
      def whitelist
        Settings.hancock_pages_blocks_whitelist
      end
      def whitelist_obj
        Settings.getnc(:hancock_pages_blocks_whitelist)
      end
      def whitelist_as_array
        whitelist.lines.map(&:strip)
      end

      def blacklist
        Settings.hancock_pages_blocks_blacklist
      end
      def blacklist_obj
        Settings.getnc(:hancock_pages_blocks_blacklist)
      end
      def blacklist_as_array
        blacklist.lines.map(&:strip)
      end

      def whitelist_human_names
        Settings.hancock_pages_blocks_human_names
      end
      def whitelist_human_names_obj
        Settings.getnc(:hancock_pages_blocks_human_names)
      end


      def whitelist_enum
        # whitelist_as_array.map do |f|
        [whitelist_as_array - blacklist_as_array].map do |f|
          whitelist_human_names[f] ? ["#{whitelist_human_names[f]} (#{f})", f] : [f]
        end
      end


      def add_view_in_whitelist(path = "", name = "")
        if path.is_a?(Hash)
          path, name = path[:path], path[:name]
        end
        return nil if path.blank?
        path.strip!
        current_whitelist_array = whitelist_as_array
        ret = true
        if current_whitelist_array.include?(path)
          ret = false
          current_whitelist_array << path
          whitelist_obj.update(raw: current_whitelist_array.join("\n"))
        end
        unless name.blank?
          current_whitelist_human_names = whitelist_human_names
          unless current_whitelist_human_names.keys.include?(path)
            current_whitelist_human_names[path] = name
            whitelist_human_names_obj.update(raw: current_whitelist_human_names.to_yaml)
          end
        end
        return ret
      end

      def add_view_in_blacklist(path)
        if path.is_a?(Hash)
          path, path[:path]
        end
        return nil if path.blank?
        path.strip!
        current_blacklist_array = blacklist_as_array
        ret = true
        if current_blacklist_array.include?(path)
          ret = false
          current_blacklist_array << path
          blacklist_obj.update(raw: current_blacklist_array.join("\n"))
        end
        return ret
      end

    end

  end

end
