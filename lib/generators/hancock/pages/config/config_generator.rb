require 'rails/generators'

module Hancock::Pages
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'Hancock::Pages Config generator'
    def config
      template 'hancock_pages.erb', "config/initializers/hancock_pages.rb"
    end

  end
end
