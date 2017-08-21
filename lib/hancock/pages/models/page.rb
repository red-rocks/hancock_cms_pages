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

        REGEXP = Hancock::InsertionField::REGEXP.merge({
          new_helper: /\[\[\[\[(?<new_helper>(?<new_helper_name>\w+?))\]\]\]\]/i,
          old_helper: /\{\{(?<old_helper>HELPER\|(?<old_helper_name>\w+?))\}\}/i,
          helper:     /(\[\[\[\[(?<helper>(?<helper_name>\w+?))\]\]\]\]|\{\{(?<helper>HELPER\|(?<helper_name>\w+?))\}\})/i,
          new_bs:     /\[\[(?<new_bs>(?<new_bs_name>\w+?))\]\]/i,
          old_bs:     /\{\{(?<old_bs>BS\|(?<old_bs_name>\w+?))\}\}/i,
          bs:         /(\[\[(?<bs>(?<bs_name>\w+?))\]\]|\{\{(?<bs>BS\|(?<bs_name>\w+?))\}\})/i,
          file:       /\{\{(?<file>FILE)\}\}/i
        })
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

        before_save do
          self.hancock_connectable_id = nil   if self.hancock_connectable_id.nil?
          self.hancock_connectable_type = nil if self.hancock_connectable_type.nil?
          self
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
              _excerpt = excerpt.gsub(REGEXP[:bs]) do
                bs = Hancock::Pages::Blockset.enabled.where(name: $~[:bs_name]).first
                if bs
                  begin
                    view.render_blockset(bs, called_from: {object: self, method: :page_excerpt})
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
              end.gsub(REGEXP[:insertion]) do |data|
                if Hancock::Pages.config.insertions_support
                  get_insertion($~[:insertion_name])
                else
                  data
                end

              end.gsub(REGEXP[:settings]) do
                if defined?(Settings)
                  name = $~[:setting_name]
                  if !name.blank?
                    Settings.ns(ns).get(name) rescue ""
                  else
                    ""
                  end
                end

              end.gsub(REGEXP[:settings_with_ns]) do
                if defined?(Settings)
                  ns = $~[:setting_with_ns_ns]
                  name = $~[:setting_with_ns_name]
                  if ns != "self" and !name.blank?
                    Settings.ns(ns).get(name) rescue ""
                  else
                    ""
                  end
                end
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
              _content = content.gsub(REGEXP[:bs]) do
                bs = Hancock::Pages::Blockset.enabled.where(name: $~[:bs_name]).first
                if bs
                  begin
                    view.render_blockset(bs, called_from: {object: self, method: :page_excerpt})
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
              end.gsub(REGEXP[:insertion]) do |data|
                if Hancock::Pages.config.insertions_support
                  get_insertion($~[:insertion_name])
                else
                  data
                end

              end.gsub(REGEXP[:settings]) do
                if defined?(Settings)
                  name = $~[:setting_name]
                  if !name.blank?
                    Settings.ns(ns).get(name) rescue ""
                  else
                    ""
                  end
                end

              end.gsub(REGEXP[:settings_with_ns]) do
                if defined?(Settings)
                  ns = $~[:setting_with_ns_ns]
                  name = $~[:setting_with_ns_name]
                  if ns != "self" and !name.blank?
                    Settings.ns(ns).get(name) rescue ""
                  else
                    ""
                  end
                end
              end
              @content_used = true
              _content
            end
          else
            ''
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
        def wrapper_attributes_str
          self[:wrapper_attributes] ||= self.wrapper_attributes.to_json if self.wrapper_attributes
        end

      end


      class_methods do

        def manager_can_add_actions
          ret = [:nested_set]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Pages.mongoid?
          ret << :model_settings if Hancock::Pages.config.model_settings_support
          # ret << :model_accesses if Hancock::Pages.config.user_abilities_support
          ret << :hancock_touch if Hancock::Pages.config.cache_support
          ret += [:comments, :model_comments] if Hancock::Pages.config.ra_comments_support
          ret.freeze
        end
        def rails_admin_add_visible_actions
          ret = [:nested_set]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Pages.mongoid?
          ret << :model_settings if Hancock::Pages.config.model_settings_support
          ret << :model_accesses if Hancock::Pages.config.user_abilities_support
          ret << :hancock_touch if Hancock::Pages.config.cache_support
          ret += [:comments, :model_comments] if Hancock::Pages.config.ra_comments_support
          ret.freeze
        end

      end

    end
  end
end
