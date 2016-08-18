Hancock.rails_admin_configure do |config|
  config.action_visible_for :nested_set, 'Hancock::Pages::Page'
  if Hancock::Pages.active_record?
    config.action_visible_for :nested_set, 'Hancock::Pages::Blockset'
  end

  if Hancock::Pages.mongoid?
    config.action_visible_for :sort_embedded, 'Hancock::Pages::Blockset'
  end

  config.action_visible_for :toggle_menu, 'Hancock::Pages::Page'

  if defined?(RailsAdminComments)
    config.action_visible_for :comments, 'Hancock::Pages::Menu'
    config.action_visible_for :comments, 'Hancock::Pages::Page'
    config.action_visible_for :comments, 'Hancock::Pages::Blockset'
    config.action_visible_for :model_comments, 'Hancock::Pages::Menu'
    config.action_visible_for :model_comments, 'Hancock::Pages::Page'
    config.action_visible_for :model_comments, 'Hancock::Pages::Blockset'
    if Hancock::Pages.active_record?
      config.action_visible_for :comments, 'Hancock::Pages::Block'
      config.action_visible_for :model_comments, 'Hancock::Pages::Block'
    end
  end
end
