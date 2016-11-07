require 'rails/generators'

module Hancock::Pages::Models
  class PageGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :class_name_arg, type: :string, default: ""

    desc 'Hancock::Pages Page Model generator'
    def page
      template 'page.erb', "app/models/#{file_name}.rb"
    end

    private
    def class_name
      class_name_arg.blank? ? "SetClassForPage" : class_name_arg
    end

    def capitalized_class_name
      class_name.capitalize
    end

    def camelcased_class_name
      class_name.camelcase
    end

    def file_name
      underscored_class_name
    end

    def underscored_class_name
      camelcased_class_name.underscore
    end

    def underscored_pluralized_class_name
      underscored_class_name.pluralize
    end

  end
end
