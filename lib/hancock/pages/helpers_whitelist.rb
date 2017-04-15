module Hancock::Pages::HelpersWhitelist

  def self.included(base)

    class << base
      def helpers_whitelist
        (Settings.hancock_pages_blocks_helpers_whitelist || {})
      end
      def helpers_whitelist_obj
        Settings.getnc(:hancock_pages_blocks_helpers_whitelist)
      end
      def helpers_whitelist_as_array(exclude_blacklist = false)
        _list = helpers_whitelist.lines.map(&:strip).uniq
        (exclude_blacklist ? (_list - helpers_blacklist_as_array) : _list)
      end
      def can_render_helper_in_block?(name)
        helpers_whitelist_as_array(true).include?(name)
      end

      def helpers_blacklist
        {}
        # (Settings.ns('admin').hancock_pages_blocks_helpers_blacklist || {})
      end
      def helpers_blacklist_obj
        nil
        # Settings.ns('admin').getnc(:hancock_pages_blocks_helpers_blacklist)
      end
      def helpers_blacklist_as_array
        []
        # helpers_blacklist.lines.map(&:strip).uniq
      end

      def helpers_whitelist_human_names
        (Settings.helpers_whitelist || {})
      end
      def helpers_whitelist_human_names_obj
        Settings.getnc(:helpers_human_names)
      end


      def helpers_whitelist_enum
        # helpers_whitelist_as_array.map do |f|
        # (helpers_whitelist_as_array - helpers_blacklist_as_array).uniq.map do |f|
        helpers_whitelist_as_array(true).map do |f|
          # helpers_whitelist_human_names[f] ? ["#{helpers_whitelist_human_names[f]} (#{f})", f] : f
          helpers_whitelist_human_names[f] ? "#{helpers_whitelist_human_names[f]} (#{f})" : f
        end
      end

    end

  end

end
