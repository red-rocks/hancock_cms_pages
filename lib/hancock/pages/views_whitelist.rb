module Hancock::Pages::ViewsWhitelist

  def self.included(base)

    class << base
      def whitelist
        Settings.hancock_pages_blocks_whitelist
      end
      def whitelist_obj
        Settings.getnc(:hancock_pages_blocks_whitelist)
      end
      def whitelist_as_array(exclude_blacklist = false)
        _list = whitelist.lines.map(&:strip).uniq
        (exclude_blacklist ? (_list - blacklist_as_array) : _list)
      end
      def can_render_in_block?(path)
        whitelist_as_array(true).include?(path)
      end

      def blacklist
        Settings.hancock_pages_blocks_blacklist
      end
      def blacklist_obj
        Settings.getnc(:hancock_pages_blocks_blacklist)
      end
      def blacklist_as_array
        blacklist.lines.map(&:strip).uniq
      end

      def whitelist_human_names
        Settings.hancock_pages_blocks_human_names
      end
      def whitelist_human_names_obj
        Settings.getnc(:hancock_pages_blocks_human_names)
      end

      def format_virtual_path(virtual_path, is_partial = nil)
        if virtual_path.is_a?(Hash)
          virtual_path, is_partial = virtual_path[:virtual_path], virtual_path[:is_partial]
        end
        _virtual_path = virtual_path.clone
        path_parts = _virtual_path.split("/")
        is_partial = path_parts.last[0] == "_" if is_partial.nil?
        if is_partial
          fname = path_parts.pop
          _virtual_path = (path_parts << fname[1..-1]).join("/")
        end
        _virtual_path
      end


      def whitelist_enum
        # whitelist_as_array.map do |f|
        [whitelist_as_array - blacklist_as_array].uniq.map do |f|
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
        unless current_whitelist_array.include?(path)
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
          path = path[:path]
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
