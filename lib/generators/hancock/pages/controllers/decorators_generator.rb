require 'rails/generators'

module Hancock::Pages::Controllers
  class DecoratorsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../../../../app/controllers/concerns/hancock/pages/decorators', __FILE__)
    argument :controllers, type: :array, default: []

    desc 'Hancock::Pages Controllers generator'
    def decorators
      copied = false
      (controllers == ['all'] ? permitted_controllers : controllers & permitted_controllers).each do |c|
        copied = true
        copy_file "#{c}.rb", "app/controllers/concerns/hancock/pages/decorators/#{c}.rb"
      end
      puts "U need to set controllers`s name. One of this: #{permitted_controllers.join(", ")}." unless copied
    end

    private
    def permitted_controllers
      ['pages']
    end

  end
end
