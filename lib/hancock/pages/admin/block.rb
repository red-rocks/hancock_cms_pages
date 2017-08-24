module Hancock::Pages
  module Admin
    module Block
      def self.config(nav_label = nil, fields = {})
        if nav_label.is_a?(Hash)
          nav_label, fields = nav_label[:nav_label], nav_label
        elsif nav_label.is_a?(Array)
          nav_label, fields = nil, nav_label
        end

        Proc.new {
          navigation_label(!nav_label.blank? ? nav_label : I18n.t('hancock.pages'))
          object_label_method :rails_admin_label

          field :enabled, :toggle do
            searchable false
          end
          field :show_in_menu, :toggle do
            searchable false
          end
          field :render_file, :toggle do
            searchable false
          end
          field :partial, :toggle do
            searchable false
          end
          field :name do
            searchable true
          end
          field :menu_link_content, :text do
            searchable true
          end
          field :pageblock_selector, :string do
            searchable true
          end

          # field :file_path, :string do
          #   searchable true
          # end
          field :file_path, :hancock_enum do
            enum do
              Hancock::Pages.views_whitelist_enum || []
            end
            multiple false
            searchable true
            help do
              ret = []
              _links = []
              if bindings[:view]._current_user and bindings[:view]._current_user.admin?
                _name = "Исходник текущего файла (#{bindings[:object].file_path})"
                _links << bindings[:view].link_to(_name, "#", onclick: "$(this).siblings('pre').addClass('hidden').filter('.source').removeClass('hidden'); return false;")
                ret << "<pre class='source hidden'><code>#{CGI.escapeHTML bindings[:object].file_source_code}</code></pre>"
              end
              if Hancock::Pages.config.cache_support and (_frag = bindings[:object].possible_cache_fragment)
                _name = "Возможный фрагмент кеша"
                _links << bindings[:view].link_to(_name, "#", onclick: "$(this).siblings('pre').addClass('hidden').filter('.cache').removeClass('hidden'); return false;")
                ret << "<pre class='cache hidden'><code>#{CGI.escapeHTML(_frag.data)}</code></pre>"
              end
              _links << bindings[:view].link_to("Скрыть все", "#", onclick: "$(this).siblings('pre').addClass('hidden'); return false;")
              [_links.join(" | "), ret].flatten.join.html_safe
            end
          end
          field :content, :hancock_html do
            searchable true
          end

          group :wrapper, &Hancock::Pages::Admin.wrapper_block

          if Hancock::Pages.config.insertions_support
            group :insertions, &Hancock::Admin.insertions_block
          end

          Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)
          if block_given?
            yield self
          end
        }
      end
    end
  end
end
