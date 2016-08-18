require 'rails/generators'
require 'rails/generators/active_record'

module Hancock::Pages
  class MigrationGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)

    desc 'Hancock Pages migration generator'
    def install
      if Hancock.active_record?
        %w(pages blocks).each do |table_name|
          migration_template "migration_#{table_name}.rb", "db/migrate/hancock_create_#{table_name}.rb"
        end
      end
    end
  end
end
