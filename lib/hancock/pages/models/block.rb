module Hancock::Pages
  module Models
    module Block
      extend ActiveSupport::Concern
      include Hancock::Model
      include Hancock::Enableable
      include ManualSlug

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


      def has_content?
        @content_used.nil? && !content.blank?
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
            _content = content.gsub(/\{\{(([^\.]*?)\.)?(.*?)\}\}/) do
              if $3 == "FILE" and $2.blank?
                clear_insertions ? "" : $0
              elsif $3 =~ /\ABS\|(.*?)\Z/ and $2.blank?
                clear_insertions ? "" : $0
              else
                (Settings and !$3.blank?) ? Settings.ns($2).get($3).val : "" #temp
              end
            end
            @content_used = true
            _content
          end
        else
          ''
        end
      end
      def has_content_html?
        @content_html_used.nil? && !content_html.blank?
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
            _content_html = content_html.gsub(/\{\{(([^\.]*?)\.)?(.*?)\}\}/) do
              if $3 == "FILE" and $2.blank?
                clear_insertions ? "" : $0
              elsif $3 =~ /\ABS\|(.*?)\Z/ and $2.blank?
                clear_insertions ? "" : $0
              else
                (Settings and !$3.blank?) ? Settings.ns($2).get($3).val : "" #temp
              end
            end
            @content_html_used = true
            _content_html
          end
        else
          ''
        end
      end

      def render_or_content_html(view = ApplicationController.new, opts = {})
        if view.is_a?(Hash)
          view, opts = view.delete(:view) || ApplicationController.new, view
        end
        ret = ""
        hancock_env = {block: self, called_from: [:render_or_content_html]}
        hancock_env[:called_from].unshift(opts.delete(:called_from)) if opts and opts[:called_from].present?
        locals = {}
        locals[:hancock_env] = hancock_env

        if self.render_file and !self.file_path.blank?
          opts.merge!(partial: self.file_path, locals: locals)
          # ret = view.render_to_string(opts) rescue self.content_html.html_safe
          puts opts.inspect
          puts view.request
          begin
            # ret = view.render_to_string(opts)
            ret = view.render(opts)
          rescue Exception => ex
            # puts ex.message
            puts ex.backtrace
          end
        else
          opts.merge!(partial: self.file_path, locals: locals)
          ret = self.block_content_html(false).gsub("{{FILE}}") do
            # view.render_to_string(opts) rescue nil
            view.render(opts) rescue nil
          end.gsub(/\{\{BS\|(.*?)\}\}/) do
            bs = Hancock::Pages::Blockset.enabled.where(name: $1).first
            view.render_blockset(bs, called_from: :render_or_content_html) rescue nil if bs
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
        return ret
      end

      def render_or_content(view = ApplicationController.new, opts = {})
        if view.is_a?(Hash)
          view, opts = view.delete(:view) || ApplicationController.new, view
        end
        ret = ""
        hancock_env = {block: self, called_from: [:render_or_content]}
        hancock_env[:called_from].unshift(opts.delete(:called_from)) if opts and opts[:called_from].present?
        locals = {}
        locals[:hancock_env] = hancock_env

        unless self.file_path.blank?
          opts.merge!(partial: self.file_path, locals: locals)
          # ret = view.render_to_string(opts) rescue self.content
          ret = view.render(opts) rescue self.content
        else
          opts.merge!(partial: self.file_path, locals: locals)
          ret = self.block_content(false).gsub("{{FILE}}") do
            # view.render_to_string(opts) rescue nil
            view.render(opts) rescue nil
          end.gsub(/\{\{BS\|(.*?)\}\}/) do
            bs = Hancock::Pages::Blockset.enabled.where(name: $1).first
            view.render_blockset(bs, called_from: :render_or_content_html) rescue nil if bs
          end
        end
        ret = yield ret if block_given?
        return ret
      end

      def file_fullpath(with_ext = false, ext = ".html.slim")
        if with_ext.is_a?(String)
          ext, with_ext = with_ext, true
        end
        ret = nil
        unless self.file_path.blank?
          ret = self.file_path_for_fs
          ret += ext if with_ext
          ret = Rails.root.join("views", ret)
        end
        return ret
      end
      def file_exists?
        file_fullpath(true).exist?
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
