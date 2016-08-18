module Hancock::Pages
  module Admin
    module Menu
      def self.config(fields = {})
        Proc.new {
          navigation_label I18n.t('hancock.pages')

          field :enabled, :toggle do
            searchable false
          end
          field :text_slug do
            searchable true
          end
          field :name do
            searchable true
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
