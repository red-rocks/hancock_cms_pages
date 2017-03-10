module Hancock::Pages
  module Admin
    module Blockset
      def self.config(nav_label = nil, fields = {})
        if nav_label.is_a?(Hash)
          nav_label, fields = nav_label[:nav_label], nav_label
        elsif nav_label.is_a?(Array)
          nav_label, fields = nil, nav_label
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

          group :blocks do
            weight 10
            active false
            field :blocks do
              eager_load(false) rescue nil
              queryable true
              searchable  do
                [
                  {blocks: :_id},
                  {blocks: :name},
                  {blocks: :menu_link_content},
                  {blocks: :pageblock_selector},
                  {blocks: :file_path},
                  {blocks: :content_html}
                ]
              end
              # searchable_columns do
              #   [
              #     { column: "#{abstract_model.table_name}.blocks.name",   type: :string },
              #     { column: "#{abstract_model.table_name}.blocks.menu_link_content",  type: :string },
              #     { column: "#{abstract_model.table_name}.blocks.pageblock_selector",  type: :string },
              #     { column: "#{abstract_model.table_name}.blocks.file_path",  type: :string },
              #     { column: "#{abstract_model.table_name}.blocks.content_html",  type: :string }
              #   ]
              # end
            end
          end

          group(:wrapper, &Hancock::Pages::Admin.wrapper_block do
            weight 5
          end)
          # group :wrapper do
          #   active false
          #   field :use_wrapper, :toggle
          #   field :wrapper_tag, :string
          #   field :wrapper_class, :string
          #   field :wrapper_id, :string
          #   field :wrapper_attributes, :text do
          #     formatted_value do
          #       bindings[:object] and bindings[:object].wrapper_attributes ? bindings[:object].wrapper_attributes.to_json : "{}"
          #     end
          #   end
          # end

          Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)

          # field :blocks do
          #   read_only true
          #   help 'Список блоков'
          #
          #   pretty_value do
          #     bindings[:object].blocks.to_a.map { |b|
          #       route = (bindings[:view] || bindings[:controller])
          #       model_name = b.rails_admin_model
          #       route.link_to(b.name, route.rails_admin.show_path(model_name: model_name, id: b.id), title: b.name)
          #     }.join("<br>").html_safe
          #   end
          # end

          sort_embedded(
            {
              fields: [:blocks]
            }
          )

          if block_given?
            yield self
          end
        }
      end
    end
  end
end
