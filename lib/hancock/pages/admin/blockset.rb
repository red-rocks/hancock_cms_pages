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
          navigation_icon('mdi mdi-television-guide')
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
                  {blocks: :id},
                  {blocks: :name},
                  {blocks: :menu_link_content},
                  {blocks: :pageblock_selector},
                  {blocks: :file_path},
                  {blocks: :content_html}
                ]
              end
            end
          end

          group(:wrapper, &Hancock::Pages::Admin.wrapper_block do
            weight 5
          end)

          Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)

          if Hancock::Pages.mongoid?
            sort_embedded(
              {
                fields: [:blocks],
                label_methods: [:name, :title, :label, :rails_admin_label]
              }
            )
          end

          if block_given?
            yield self
          end
        }
      end
    end
  end
end
