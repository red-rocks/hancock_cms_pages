module Hancock::Pages::Blocksetable
  extend ActiveSupport::Concern
  included do
    helper_method :render_blockset
    helper_method :blockset_navigation
  end

  def blockset_navigation(type)
    Proc.new do |primary|
      SimpleNavigation.config.autogenerate_item_ids = false
      begin
        blockset_nav_extra_data_before(type, primary)
        all_items = blockset_nav_get_menu_items(type)
        items = all_items#.select { |i| i.parent_id.nil? && !i.name.blank? && i.enabled }
        items.each do |item|
          # render_with_subs(all_items, primary, item)
          blockset_navigation_item(primary, item)
        end
        blockset_nav_extra_data_after(type, primary)
      rescue Exception => exception
        Rails.logger.error exception.message
        Rails.logger.error exception.backtrace.join("\n")
        puts exception.message
        puts exception.backtrace.join("\n")
        Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
        items || []
      end
    end
  end

  def render_blockset(*opts)
    if opts.length == 1 and opts[0].is_a?(Hash)
      type = opts.delete[:type]
    else
      if opts[-1].is_a?(Hash)
        type = opts[-2] #backward compatibility
        opts = opts[-1]
      else
        type = opts[-1] #backward compatibility
        opts = {}
      end
    end
    ret = []
    begin
      blockset = get_blockset(type)
      blocks = blockset_get_blocks_for_render(blockset)
      blocks.each do |block|
        ret << block.render_or_content_html(self, opts) do |html|
          after_render_blockset_block block, html
        end
      end
      ret = blockset.render(self, ret.join.html_safe) do |html|
        after_render_blockset blockset, html
      end
    rescue Exception => exception
      Rails.logger.error exception.message
      Rails.logger.error exception.backtrace.join("\n")
      puts exception.message
      puts exception.backtrace.join("\n")
      Raven.capture_exception(exception) if Hancock::Pages.config.raven_support
      # ret << blocks || []
    end
    return (ret.is_a?(Array) ? ret.join.html_safe : ret)
  end

  private
  def after_render_blockset_block(block, html)
    html
  end

  def after_render_blockset(blockset, html)
    html
  end

  def get_blockset(type)
    type.is_a?(Hancock::Pages::Blockset) ? type : blockset_class.find(type.to_s)
  end

  def blockset_get_blocks(type)
    blockset = get_blockset type
    blockset.blocks.enabled.show_in_menu.sorted.to_a if blockset
  end

  def blockset_get_blocks_for_render(type)
    blockset = get_blockset type
    blockset.blocks.enabled.sorted.to_a if blockset
  end

  def blockset_class_name
    "Hancock::Pages::Blockset"
  end
  def blockset_class
    blockset_class_name.constantize
  end

  def blockset_navigation_item(primary, item, block=nil)
    url = item.pageblock_selector.blank? ? item.slug : item.pageblock_selector #"javascript:;"
    content = item.menu_link_content.blank? ? item.name : item.menu_link_content.html_safe
    if block.nil?
      primary.item(item.slug, content, url, item.nav_options)
    else
      primary.item(item.slug, content, url, item.nav_options, &block)
    end
  end

  def blockset_nav_get_menu_items(type)
    blockset_get_blocks(type)
  end
  def blockset_nav_extra_data_before(type, primary)
    # override for additional config or items
  end
  def blockset_nav_extra_data_after(type, primary)
    # override for additional config or items
  end
end
