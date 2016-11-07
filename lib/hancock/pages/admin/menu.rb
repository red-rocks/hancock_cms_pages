module Hancock::Pages
  module Admin
    module Menu
      def self.config(nav_label = nil, fields = {})
        if nav_label.is_a?(Hash)
          nav_label, fields = nav_label[:nav_label], nav_label
        end
        Proc.new {
          navigation_label(!nav_label.blank? ? nav_label : I18n.t('hancock.pages'))

          field :enabled, :toggle do
            searchable false
          end
          field :text_slug do
            searchable true
          end
          field :name do
            searchable true
          end
          field :add_page do
            pretty_value do
              _model = bindings[:object].page_class.rails_admin_model
              bindings[:view].link_to(
                'Добавить Страницу',
                bindings[:view].new_path(model_name: _model, "#{_model}[menu_ids][]": bindings[:object]._id.to_s),
                class: 'label label-info'
              )
            end
            visible do
              bindings[:controller].action_name == 'index'
            end
            formatted_value {}
          end

          group :caching, &Hancock::Admin.caching_block

          Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)

          if block_given?
            yield self
          end
        }
      end
    end
  end
end
