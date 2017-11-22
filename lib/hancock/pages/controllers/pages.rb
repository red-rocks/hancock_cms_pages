module Hancock::Pages
  module Controllers
    module Pages
      extend ActiveSupport::Concern

      def show
        if @seo_page.nil? || !@seo_page.persisted?
          if !params[:id].blank? or !params[:slug].blank?
            @seo_page = model.enabled.find(params[:id] || params[:slug])
          end
        end
        after_initialize
        if @seo_page.nil?
          render_404
          return true
        end

        if Hancock::Pages.config.breadcrumbs_on_rails_support
          add_breadcrumb @seo_page.name, @seo_page.get_fullpath
        end

        layout_name = nil
        layout_name = @seo_page.layout_name unless @seo_page.layout_name.blank?
        if layout_name
          if Hancock::Pages.config.available_layouts.include?(layout_name)
            render layout: layout_name
          end
        else
          render html: @seo_page.page_content(self).html_safe, layout: nil
        end
      end

      private
      def model
        Hancock::Pages::Page
      end

      def after_initialize
      end

    end
  end
end
