module Hancock::Pages
  module Admin
    module Page
      def self.config(nav_label = nil, fields = {})
        if nav_label.is_a?(Hash)
          nav_label, fields = nav_label[:nav_label], nav_label
        elsif nav_label.is_a?(Array)
          nav_label, fields = nil, nav_label
        end
        Proc.new {
          navigation_label(!nav_label.blank? ? nav_label : I18n.t('hancock.pages'))

          list do
            scopes [:sorted, :enabled, nil]

            field :enabled, :toggle do
              searchable false
            end
            field :menus, :menu do
              searchable :name
            end
            field :name do
              searchable true
            end
            field :hancock_connectable do
              searchable :name
            end
            field :fullpath do
              searchable true
              pretty_value do
                bindings[:view].content_tag(:a, bindings[:object].fullpath, href: bindings[:object].fullpath)
              end
            end
            field :redirect do
              searchable true
            end
            field :slug do
              searchable true
              searchable_columns do
                [{column: "#{abstract_model.table_name}._slugs", type: :string}]
              end
              queryable true
            end

            group :content, &Hancock::Admin.content_block(excluded_fields: [:excerpt])
            if Hancock::Pages.config.cache_support
              group :caching, &Hancock::Cache::Admin.caching_block
            end
          end

          edit do
            field :enabled, :toggle
            field :name
            field :hancock_connectable do
              read_only true
            end

            group :content, &Hancock::Admin.content_block(excluded_fields: [:excerpt])
            # group :content do
            #   active false
            #   field :excerpt, :hancock_html
            #   # field :excerpt_html, :ck_editor
            #   # field :excerpt_clear, :toggle
            #   field :content, :hancock_html
            #   # field :content_html, :ck_editor
            #   # field :content_clear, :toggle
            # end

            group :wrapper, &Hancock::Pages::Admin.wrapper_block


            group :menu, &Hancock::Pages::Admin.menu_block
            # group :menu do
            #   active false
            #   label I18n.t('hancock.menu_title')
            #   field :menus
            #   field :fullpath, :string do
            #     help I18n.t('hancock.with_final_slash')
            #   end
            #   field :regexp, :string do
            #     help I18n.t('hancock.page_url_regex')
            #   end
            #   field :redirect, :string do
            #     help I18n.t('hancock.final_in_menu')
            #   end
            #   field :text_slug
            # end

            if Hancock::Pages.config.cache_support
              group :caching, &Hancock::Cache::Admin.caching_block
            end

            Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)

            if Hancock::Pages.config.seo_support
              group :seo_n_sitemap, &Hancock::Seo::Admin.seo_n_sitemap_block
            end
            # group :seo do
            #   active false
            #   field :seo
            # end
            # group :sitemap_data do
            #   active false
            #   field :sitemap_data
            # end

            if Hancock::Pages.config.cache_support
              group :caching, &Hancock::Cache::Admin.caching_block
            end
          end

          nested_set({
            max_depth: Hancock::Pages.config.menu_max_depth,
            scopes: []
          })

          if block_given?
            yield self
          end
        }
      end
    end
  end
end
