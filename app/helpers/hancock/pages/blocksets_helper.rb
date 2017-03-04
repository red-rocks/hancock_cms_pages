module Hancock::Pages::BlocksetsHelper

  # def capture_block(&block)
  #   capture(&block)
  # end

  def hancock_pages_blocks_can_render_me(name = "", opts = {})
    if name.is_a?(Hash)
      name, opts = (name.delete(:name) || ""), name
    end
    _virtual_path = @virtual_path.clone
    path_parts = _virtual_path.split("/")
    is_partial = (opts.keys.include?(:partial) ? opts[:partial] : path_parts.last[0] == "_")
    if is_partial
      fname = path_parts.pop
      _virtual_path = (path_parts << fname[1..-1]).join("/")
    end
    Hancock::Pages::add_view_in_whitelist(_virtual_path, name)
  end
  alias_method :hancock_pages_blocks_can_render_me_as, :hancock_pages_blocks_can_render_me

  def hancock_pages_blocks_cannot_render_me(opts = {})
    _virtual_path = @virtual_path.clone
    path_parts = _virtual_path.split("/")
    is_partial = (opts.keys.include?(:partial) ? opts[:partial] : path_parts.last[0] == "_")
    if is_partial
      fname = path_parts.pop
      _virtual_path = (path_parts << fname[1..-1]).join("/")
    end
    Hancock::Pages::add_view_in_blacklist(_virtual_path)
  end

end
