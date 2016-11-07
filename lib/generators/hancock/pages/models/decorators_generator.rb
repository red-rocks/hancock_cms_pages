require 'rails/generators'

module Hancock::Pages::Models
  class DecoratorsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../../../../app/models/concerns/hancock/pages/decorators', __FILE__)
    argument :models, type: :array, default: []

    desc 'Hancock::Pages Models decorators generator'
    def decorators
      copied = false
      (models == ['all'] ? permitted_models : models & permitted_models).each do |m|
        copied = true
        copy_file "#{m}.rb", "app/models/concerns/hancock/pages/decorators/#{m}.rb"
      end
      puts "U need to set models`s name. One of this: #{permitted_models.join(", ")}." unless copied
    end

    private
    def permitted_models
      ['page', 'menu', 'block', 'blockset']
    end

  end
end
