module Hancock::Pages::PagesHelper

  def cached_navigation(key = :main)
    if @seo_page
      cache @seo_page do
        render_navigation &navigation(key)
    elsif @seo_parent_page
      cache @seo_parent_page do
        render_navigation &navigation(key)
    else
      render_navigation &navigation(key)
    end
  end

end
