module Hancock::Pages
  module Admin
    module Page
      def self.config(fields = {})
        Proc.new {
          navigation_label I18n.t('hancock.pages')

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
            field :connectable do
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
            end
          end

          edit do
            field :enabled, :toggle
            field :name
            field :connectable do
              read_only true
            end

            group :content do
              active false
              field :excerpt, :hancock_html
              # field :excerpt_html, :ck_editor
              # field :excerpt_clear, :toggle
              field :content, :hancock_html
              # field :content_html, :ck_editor
              # field :content_clear, :toggle
            end

            group :menu do
              active false
              label I18n.t('hancock.menu_title')
              field :menus
              field :fullpath, :string do
                help I18n.t('hancock.with_final_slash')
              end
              field :regexp, :string do
                help I18n.t('hancock.page_url_regex')
              end
              field :redirect, :string do
                help I18n.t('hancock.final_in_menu')
              end
              field :text_slug
            end

            Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)

            group :seo do
              active false
              field :seo do
                active true
              end
            end
            group :sitemap_data do
              active false
              field :sitemap_data do
                active true
              end
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
