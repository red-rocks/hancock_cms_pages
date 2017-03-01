module Hancock::Pages
  module Models
    module Page
      extend ActiveSupport::Concern
      include Hancock::Model
      include Hancock::Enableable
      include ManualSlug
      if Hancock::Pages.config.seo_support
        include Hancock::Seo::Seoable
        include Hancock::Seo::SitemapDataField
      end

      if Hancock::Pages.config.cache_support
        include Hancock::Cache::Cacheable
      end
      if Hancock::Pages.config.insertions_support
        include Hancock::InsertionField
      end

      include Hancock::Pages.orm_specific('Page')

      # if Hancock.config.search_enabled
      #   include Hancock::ElasticSearch
      # end

      included do
        acts_as_nested_set

        validates_uniqueness_of :fullpath
        validates_presence_of :name
        manual_slug :name
        before_validation do
          self.fullpath = "/pages/#{slug}" if self.fullpath.blank?
        end


        if Hancock.rails4?
          belongs_to :hancock_connectable, polymorphic: true
        else
          belongs_to :hancock_connectable, polymorphic: true, optional: true
        end

        def self.goto_hancock
          self.where(hancock_connectable_type: /^Enjoy/).all.map { |s|
            s.hancock_connectable_type = s.hancock_connectable_type.sub("Enjoy", "Hancock");
            s.save
          }
        end

        before_save do
          self.hancock_connectable_id = nil   if self.hancock_connectable_id.nil?
          self.hancock_connectable_type = nil if self.hancock_connectable_type.nil?
          self
        end

        def self.manager_can_add_actions
          ret = [:nested_set]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Pages.mongoid?
          ret << :model_settings if Hancock::Pages.config.model_settings_support
          # ret << :model_accesses if Hancock::Pages.config.user_abilities_support
          ret << :hancock_touch if Hancock::Pages.config.cache_support
          ret += [:comments, :model_comments] if Hancock::Pages.config.ra_comments_support
          ret.freeze
        end
        def self.rails_admin_add_visible_actions
          ret = [:nested_set]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Pages.mongoid?
          ret << :model_settings if Hancock::Pages.config.model_settings_support
          ret << :model_accesses if Hancock::Pages.config.user_abilities_support
          ret << :hancock_touch if Hancock::Pages.config.cache_support
          ret += [:comments, :model_comments] if Hancock::Pages.config.ra_comments_support
          ret.freeze
        end

        if Hancock::Pages.config.insertions_support
          insertions_for(:excerpt_html)
          insertions_for(:content_html)
        end
        def page_excerpt(view = Hancock::Pages::PagesController.new)
          if @excerpt_used.nil?
            if excerpt.nil?
              @excerpt_used = true
              ''
            else
              view.extend ActionView::Helpers::TagHelper
              view.extend ActionView::Context
              # {{BS|%blockset_name%}}
              # excerpt.gsub(/\{\{(.*?)\}\}/) do
              _excerpt = excerpt.gsub(/\{\{BS\|(.*?)\}\}/) do
                bs = Hancock::Pages::Blockset.enabled.where(name: $1).first
                if bs
                  begin
                    view.render_blockset(bs, called_from: :page_excerpt)
                  rescue Exception => exception
                    if Hancock::Pages.config.verbose_render
                      Rails.logger.error exception.message
                      Rails.logger.error exception.backtrace.join("\n")
                      puts exception.message
                      puts exception.backtrace.join("\n")
                    end
                    Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
                  end
                end

              # {{self.%insertion%}}
              end.gsub(/(\{\{self\.(.*?)\}\})/) do
                if Hancock::Pages.config.insertions_support
                  get_insertion($2)
                else
                  $1
                end

              # {{"some_text"}} #temporary disabled - need tests
              # {{"some_text"}}
              # end.gsub(/\{\{(\'|\"|&quot;|&#39;)(.*?)(\1)\}\}/) do
              #   $2

              # {{%ns%.%key%}}
              end.gsub(/\{\{(([^\.]*?)\.)?(.*?)\}\}/) do
                (Settings and !$3.nil? and $2 != "self") ? Settings.ns($2).get($3).val : "" #temp
              end
              @excerpt_used = true
              _excerpt
            end
          else
            ''
          end
        end

        def page_content(view = Hancock::Pages::PagesController.new)
          if @content_used.nil?
            if content.nil?
              @content_used = true
              ''
            else
              view.extend ActionView::Helpers::TagHelper
              view.extend ActionView::Context

              # {{BS|%blockset_name%}}
              # content.gsub(/\{\{(.*?)\}\}/) do
              _content = content.gsub(/\{\{BS\|(.*?)\}\}/) do
                bs = Hancock::Pages::Blockset.enabled.where(name: $1).first
                if bs
                  begin
                    view.render_blockset(bs, called_from: :page_content)
                  rescue Exception => exception
                    if Hancock::Pages.config.verbose_render
                      Rails.logger.error exception.message
                      Rails.logger.error exception.backtrace.join("\n")
                      puts exception.message
                      puts exception.backtrace.join("\n")
                    end
                    Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
                  end
                end

              # {{self.%insertion%}}
              end.gsub(/(\{\{self\.(.*?)\}\})/) do
                if Hancock::Pages.config.insertions_support
                  get_insertion($2)
                else
                  $1
                end

              # {{"some_text"}} #temporary disabled - need tests
              # end.gsub(/\{\{(['"])(.*?)(\1)\}\}/) do
              # end.gsub(/\{\{(\'|\"|&quot;|&#39;)(.*?)(\1)\}\}/) do
              #   $2

              # {{%ns%.%key%}}
              end.gsub(/\{\{(([^\.]*?)\.)?(.*?)\}\}/) do
                ((Settings and !$3.nil? and $2 != "self") ? Settings.ns($2).get($3).val : "") rescue "" #temp
              end
            end
            @content_used = true
            _content
          else
            ''
          end
        end
      end

      def page_h1
        _ret = seo ? seo.h1 : nil
        _ret = name   if _ret.blank?
        _ret = title  if _ret.blank?
        _ret
      end

      def get_fullpath
        redirect.blank? ? fullpath : redirect
      end

      def has_excerpt?
        @excerpt_used.nil? && !excerpt.blank?
      end


      def has_content?
        @content_used.nil? && !content.blank?
      end

      def is_current?(url)
        if fullpath == '/'
          url == '/'
        else
          url.match(clean_regexp)
        end
      end

      def regexp_prefix
        Hancock::Pages.config.localize ? "(?:#{I18n.available_locales.map { |l| "\\/#{l}"}.join("|")})?" : ""
      end

      def clean_regexp
        if regexp.blank?
          /^#{regexp_prefix}#{Regexp.escape(fullpath)}$/
        else
          begin
            /#{regexp}/
          rescue
            # not a valid regexp - treat as literal search string
            /#{Regexp.escape(regexp)}/
          end
        end
      end

      def nav_options
        nav_options_default.merge(nav_options_additions)
      end

      def nav_options_default
        {highlights_on: clean_regexp}
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
