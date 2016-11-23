require 'rails/generators'
require 'rails/generators/active_record'

module Hancock::Pages
  class MigrationsGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    desc 'Hancock Pages migrations generator'
    def migrations
      if Hancock.active_record?
        %w(pages blocks).each do |table_name|
          migration_template "migration_#{table_name}.rb", "db/migrate/hancock_create_#{table_name}.rb"
        end
      end
    end
  end
end
