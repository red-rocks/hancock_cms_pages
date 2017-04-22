module Hancock::Pages::ViewsWhitelist

  def self.included(base)

    class << base
      def views_whitelist
        (Settings.hancock_pages_blocks_views_whitelist || {})
      end
      def views_whitelist_obj
        Settings.getnc(:hancock_pages_blocks_views_whitelist)
      end
      def views_whitelist_as_array(exclude_blacklist = false, include_standalones = true)
        if exclude_blacklist.is_a?(Hash)
          exclude_blacklist, include_standalones =
            exclude_blacklist[:exclude_blacklist], exclude_blacklist[:include_standalones]
        end
        _list = views_whitelist.lines.map(&:strip).uniq
        if include_standalones
          Hancock::Pages.config.standalone_paths.each do |spath|
            spath = spath.join("/") if spath.is_a?(Array)
            _list += ActionController::Base.view_paths.paths.map { |p|
              {
                views_path: p,
                standalone_path: Pathname.new(p.to_s).join(spath)
              }
            }.select { |p| # only existed standalones path
              p[:standalone_path].exist?
            }.map { |p| # add standalones files
              p.merge(files: Dir[p[:standalone_path].join("**/*").to_s].select { |f| File.file?(f) })
            }.map { |p| # format standalones files for render path
              p[:files].map { |f|
                path = p[:views_path].to_s
                path += "/" unless path[-1] == "/"
                f.sub(path, '').sub(/(\.[^\/]+)?$/, '').sub(/\/_?([^\/]+)?$/, '/\1')
              }
            }.flatten
          end
          _list.uniq!
        end
        (exclude_blacklist ? (_list - views_blacklist_as_array) : _list)
      end
      def can_render_view_in_block?(path)
        views_whitelist_as_array(true).include?(path)
      end

      def views_blacklist
        (Settings.ns('admin').hancock_pages_blocks_views_blacklist || {})
      end
      def views_blacklist_obj
        Settings.ns('admin').getnc(:hancock_pages_blocks_views_blacklist)
      end
      def views_blacklist_as_array
        views_blacklist.lines.map(&:strip).uniq
      end

      def views_whitelist_human_names
        (Settings.hancock_pages_blocks_views_human_names || {})
      end
      def views_whitelist_human_names_obj
        Settings.getnc(:hancock_pages_blocks_views_human_names)
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


      def views_whitelist_enum
        # views_whitelist_as_array.map do |f|
        # (views_whitelist_as_array - views_blacklist_as_array).uniq.map do |f|
        views_whitelist_as_array(true).map do |f|
          views_whitelist_human_names[f] ? ["#{views_whitelist_human_names[f]} (#{f})", f] : f
        end
      end


      def add_view_in_whitelist(path = "", name = "")
        if path.is_a?(Hash)
          path, name = path[:path], path[:name]
        end
        return nil if path.blank?
        path.strip!
        current_whitelist_array = views_whitelist_as_array
        ret = true
        unless current_whitelist_array.include?(path)
          ret = false
          current_whitelist_array << path
          views_whitelist_obj.update(raw: current_whitelist_array.join("\n"))
        end
        unless name.blank?
          current_whitelist_human_names = views_whitelist_human_names
          unless current_whitelist_human_names.keys.include?(path)
            current_whitelist_human_names[path] = name
            views_whitelist_human_names_obj.update(raw: current_whitelist_human_names.to_yaml)
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
        current_blacklist_array = views_blacklist_as_array
        ret = true
        if current_blacklist_array.include?(path)
          ret = false
          current_blacklist_array << path
          views_blacklist_obj.update(raw: views_current_blacklist_array.join("\n"))
        end
        return ret
      end

    end

  end

end
