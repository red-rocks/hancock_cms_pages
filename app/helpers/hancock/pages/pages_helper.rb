module Hancock::Pages::PagesHelper

  def cached_navigation(menu_key = :main)
    render partial: 'blocks/cached_navigation', locals: {menu_key: menu_key}
  end
  def cached_navigation_main
    cached_navigation
  end

end
