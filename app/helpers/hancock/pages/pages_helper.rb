module Hancock::Pages::PagesHelper

  def cached_navigation(menu_key = :main)
    render partial: 'blocks/cached_navigation', locals: {menu_key: menu_key}
  end

  def cached_blockset_navigation(blockset_key = :main)
    render partial: 'blocks/cached_blockset_navigation', locals: {blockset_key: blockset_key}
  end

end
