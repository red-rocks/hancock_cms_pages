module Hancock::Pages
  module Models
    module Block
      extend ActiveSupport::Concern
      include Hancock::Model
      include Hancock::Enableable
      include ManualSlug

      if Hancock::Pages.config.insertions_support
        include Hancock::InsertionField
      end

      include Hancock::Pages.orm_specific('Block')

      included do
        manual_slug :name

        validates :file_path, format: {
          # with: /\A(?!layouts\/).*\Z/,
          without: /\Alayouts\/.*\Z/,
          message: "Недопустимый путь к файлу".freeze
        }

        attr_accessor :file_pathname
        after_initialize do
          self.file_pathname = Pathname.new(file_path) unless file_path.nil?
        end

        def can_render?
          Hancock::Pages::can_render_view_in_block?(self.file_path)
        end

        if Hancock::Pages.config.insertions_support
          # insertions_for(:content)
          insertions_for(:content_html)
          alias :block_content :page_content
          alias :block_content_html :page_content_html
        end
        def block_content(clear_insertions = true)
          if clear_insertions.is_a?(Hash)
            clear_insertions = clear_insertions[:clear_insertions]
          end
          if @content_used.nil?
            if content.nil?
              @content_used = true
              ''
            else
              # content.gsub(/\{\{(.*?)\}\}/) do
              # {{"some_text"}} #temporary disabled - need tests
              # _content = content.gsub(/\{\{(['"])(.*?)(\1)\}\}/) do
              #   $2
              # end.gsub(/(\{\{(([^\.]*?)\.)?(.*?)\}\})/) do
              _content = content.gsub(/(\{\{(([^\.]*?)\.)?(.*?)\}\})/) do
                if $4 == "FILE" and $3.blank?
                  clear_insertions ? "" : $1
                elsif $4 =~ /\A(BS|HELPER)\|(.*?)\Z/ and $3.blank?
                  clear_insertions ? "" : $1
                elsif $3 == "self" and !$4.blank?
                  if clear_insertions
                    ""
                  elsif Hancock::Pages.config.insertions_support
                    get_insertion($4)
                  else
                    $1
                  end
                else
                  (Settings and !$4.blank? and $3 != "self") ? Settings.ns($3).get($4).val : "" #temp
                end
              end
              @content_used = true
              _content
            end
          else
            ''
          end
        end
        def block_content_html(clear_insertions = true)
          if clear_insertions.is_a?(Hash)
            clear_insertions = clear_insertions[:clear_insertions]
          end
          if @content_html_used.nil?
            if content_html.nil?
              @content_html_used = true
              ''
            else
              # content.gsub(/\{\{(.*?)\}\}/) do
              # {{"some_text"}} #temporary disabled - need tests
              # _content_html = content_html.gsub(/\{\{(['"])(.*?)(\1)\}\}/) do
              #   $2
              # end.gsub(/(\{\{(([^\.]*?)\.)?(.*?)\}\})/) do
              _content_html = content_html.gsub(/(\{\{(([^\.]*?)\.)?(.*?)\}\})/) do
                if $4 == "FILE" and $3.blank?
                  clear_insertions ? "" : $1
                elsif $4 =~ /\A(BS|HELPER)\|(.*?)\Z/ and $3.blank?
                  clear_insertions ? "" : $1
                elsif $3 == "self" and !$4.blank?
                  if clear_insertions
                    ""
                  elsif Hancock::Pages.config.insertions_support
                    get_insertion($4)
                  else
                    $1
                  end
                else
                  (Settings and !$4.blank? and $3 != "self") ? Settings.ns($3).get($4).val : "" #temp
                end
              end
              @content_html_used = true
              _content_html
            end
          else
            ''
          end
        end
      end

      def file_pathname_as_partial
        self.file_pathname.dirname.join("_#{self.file_pathname.basename}")
      end
      def file_path_as_partial
        self.file_pathname_as_partial.to_s
      end

      def file_pathname_for_fs
        self.partial ? self.file_pathname_as_partial : self.file_pathname
      end
      def file_path_for_fs
        self.file_pathname_for_fs.to_s
      end

      def rails_admin_label
        if !self.name.blank?
          self.name
        elsif self.render_file and !self.file_path.blank?
          _human_name = Hancock::Pages.views_whitelist_human_names[self.file_path]
          if _human_name.blank?
            self.file_path_for_fs
          else
            _human_name
          end
        else
          self.id
        end
      end

      def has_content?
        @content_used.nil? && !content.blank?
      end
      def has_content_html?
        @content_html_used.nil? && !content_html.blank?
      end

      def render_or_content_html(view = Hancock::Pages::PagesController.new, opts = {})
        if view.is_a?(Hash)
          view, opts = view.delete(:view) || Hancock::Pages::PagesController.new, view
        end
        Hancock::Pages.config.renderer_lib_extends.each do |lib_extends|
          unless view.class < lib_extends
            if view.respond_to?(:prepend)
              view.prepend lib_extends
            else
              view.extend lib_extends
            end
          end
        end

        ret = ""
        hancock_env = {block: self, called_from: [{object: self, method: :render_or_content_html}]}
        hancock_env[:called_from].unshift(opts.delete(:called_from)) if opts and opts[:called_from].present?
        locals = {}
        locals[:hancock_env] = hancock_env

        if self.render_file and !self.file_path.blank?
          opts.merge!(partial: self.file_path, locals: locals)
          # ret = view.render_to_string(opts) rescue self.content_html.html_safe
          ret = begin
            view.render_to_string(opts) if can_render?
          rescue Exception => exception
            if Hancock::Pages.config.verbose_render
              Rails.logger.error exception.message
              Rails.logger.error exception.backtrace.join("\n")
              puts exception.message
              puts exception.backtrace.join("\n")
            end
            Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
            self.content_html.html_safe
          end
        else
          opts.merge!(partial: self.file_path, locals: locals)
          # ret = self.block_content_html(false).gsub(/(\{\{(([^\.]*?)\.)?(.*?)\}\})/) do
          ret = self.block_content_html(false).gsub("{{FILE}}") do
            # view.render(opts) rescue nil
            begin
              view.render(opts) if can_render?
            rescue Exception => exception
              if Hancock::Pages.config.verbose_render
                Rails.logger.error exception.message
                Rails.logger.error exception.backtrace.join("\n")
                puts exception.message
                puts exception.backtrace.join("\n")
              end
              Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
              nil
            end
          end.gsub(/\{\{BS\|(.*?)\}\}/) do
            bs = Hancock::Pages::Blockset.enabled.where(name: $1).first
            # view.render_blockset(bs, called_from: :render_or_content_html) rescue nil if bs
            if bs
              begin
                view.render_blockset(bs, called_from: {object: self, method: :render_or_content_html})
              rescue Exception => exception
                if Hancock::Pages.config.verbose_render
                  Rails.logger.error exception.message
                  Rails.logger.error exception.backtrace.join("\n")
                  puts exception.message
                  puts exception.backtrace.join("\n")
                end
                Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
                nil
              end
            end
          end.gsub(/\{\{HELPER\|(.*?)\}\}/) do
            helper_name = Hancock::Pages.views_whitelist_helpers[self.file_path]
            if helper_name
              begin
                view.__send__(helper_name)
              rescue Exception => exception
                if Hancock::Pages.config.verbose_render
                  Rails.logger.error exception.message
                  Rails.logger.error exception.backtrace.join("\n")
                  puts exception.message
                  puts exception.backtrace.join("\n")
                end
                Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
                nil
              end
            end
          end.html_safe
        end
        if use_wrapper
          _attrs = {
            class: wrapper_class,
            id: wrapper_id
          }.merge(wrapper_attributes)
          ret = view.content_tag wrapper_tag, ret, _attrs
        end
        ret = yield ret if block_given?
        return (ret.is_a?(Array) ? ret.join.html_safe : ret)
        # return ret
      end

      def render_or_content(view = Hancock::Pages::PagesController.new, opts = {})
        if view.is_a?(Hash)
          view, opts = view.delete(:view) || Hancock::Pages::PagesController.new, view
        end
        Hancock::Pages.config.renderer_lib_extends.each do |lib_extends|
          unless view.class < lib_extends
            if view.respond_to?(:prepend)
              view.prepend lib_extends
            else
              view.extend lib_extends
            end
          end
        end

        ret = ""
        hancock_env = {block: self, called_from: [{object: self, method: :render_or_content}]}
        hancock_env[:called_from].unshift(opts.delete(:called_from)) if opts and opts[:called_from].present?
        locals = {}
        locals[:hancock_env] = hancock_env

        unless self.file_path.blank?
          opts.merge!(partial: self.file_path, locals: locals)

          # ret = view.render_to_string(opts) rescue self.content
          ret = begin
            view.render_to_string(opts) if can_render?
          rescue Exception => exception
            if Hancock::Pages.config.verbose_render
              Rails.logger.error exception.message
              Rails.logger.error exception.backtrace.join("\n")
              puts exception.message
              puts exception.backtrace.join("\n")
            end
            Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
            self.content
          end
          # ret = view.render(opts) rescue self.content
        else
          opts.merge!(partial: self.file_path, locals: locals)
          ret = self.block_content(false).gsub("{{FILE}}") do
            # view.render_to_string(opts) rescue nil
            begin
              view.render_to_string(opts) if can_render?
            rescue Exception => exception
              if Hancock::Pages.config.verbose_render
                Rails.logger.error exception.message
                Rails.logger.error exception.backtrace.join("\n")
                puts exception.message
                puts exception.backtrace.join("\n")
              end
              Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
              nil
            end
            # view.render(opts) rescue nil
          end.gsub(/\{\{BS\|(.*?)\}\}/) do
            bs = Hancock::Pages::Blockset.enabled.where(name: $1).first
            # view.render_blockset(bs, called_from: :render_or_content) rescue nil if bs
            if bs
              begin
                view.render_blockset(bs, called_from: {object: self, method: :render_or_content})
              rescue Exception => exception
                if Hancock::Pages.config.verbose_render
                  Rails.logger.error exception.message
                  Rails.logger.error exception.backtrace.join("\n")
                  puts exception.message
                  puts exception.backtrace.join("\n")
                end
                Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
                nil
              end
            end
          end
        end
        ret = yield ret if block_given?
        return (ret.is_a?(Array) ? ret.join.html_safe : ret)
        # return ret
      end

      def file_fullpath(with_ext = false, ext = ".html.slim")
        if with_ext.is_a?(String)
          ext, with_ext = with_ext, true
        end
        ret = nil
        unless self.file_path.blank?
          ret = self.file_path_for_fs
          ret += ext if with_ext
          ret = Rails.root.join("app", "views", ret)
        end
        return ret
      end
      def file_exists?(ext = ".html.slim")
        !!((_filepath = file_fullpath(true, ext)) and _filepath.exist?)
      end

      def file_source_code(ext = ".html.slim")
        (file_exists?(ext) ? File.read(file_fullpath(true, ext)) : "")
      end

      def nav_options
        nav_options_default.deep_merge(nav_options_additions)
      end

      def nav_options_default
        {
          highlights_on: false,
          link_html: {
            data: {
              pageblock_selector: self.pageblock_selector,
              history_name: self.name
            }
          }
        }
      end

      def nav_options_additions
        {}
      end

      def wrapper_attributes=(val)
        if val.is_a? (String)
          begin
            begin
              self[:wrapper_attributes] = JSON.parse(val)
            rescue
              self[:wrapper_attributes] = YAML.load(val)
            end
          rescue
          end
        elsif val.is_a?(Hash)
          self[:wrapper_attributes] = val
        else
          self[:wrapper_attributes] = wrapper_attributes
        end
      end

    end
  end
end
