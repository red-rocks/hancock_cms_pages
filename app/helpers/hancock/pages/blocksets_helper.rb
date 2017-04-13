module Hancock::Pages::BlocksetsHelper

  # def capture_block(&block)
  #   capture(&block)
  # end

  def hancock_pages_blocks_can_render_me(name = "", opts = {})
    if name.is_a?(Hash)
      name, opts = (name.delete(:name) || ""), name
    end
    _virtual_path = Hancock::Pages::format_virtual_path(@virtual_path, opts[:is_partial])
    Hancock::Pages::add_view_in_whitelist(_virtual_path, name)
  end
  alias_method :hancock_pages_blocks_can_render_me_as, :hancock_pages_blocks_can_render_me

  def hancock_pages_blocks_can_render_me?(opts = {})
    _virtual_path = Hancock::Pages::format_virtual_path(@virtual_path, opts[:is_partial])
    Hancock::Pages::whitelist_as_array(opts[:exclude_blacklist]).include?(_virtual_path)
  end

  def hancock_pages_blocks_cannot_render_me(opts = {})
    _virtual_path = Hancock::Pages::format_virtual_path(@virtual_path)
    Hancock::Pages::add_view_in_blacklist(_virtual_path)
  end

  def hancock_env
    {
      block: ::Hancock::Pages::Block.new,
      page: ::Hancock::Pages::Page.new,
      called_from: []
    }
  end

end
