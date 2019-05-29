class HancockPagesCreatePages < ActiveRecord::Migration[5.1]
  def change
    create_table :hancock_pages_menus do |t|

      if Hancock.config.localize
        if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
          t.json :name_translations
        else
          t.column :name_translations, 'hstore'
        end
      else
        t.string :name, null: false
      end
      t.string :slug, null: false
      t.timestamps
    end
    add_index :hancock_pages_menus, :slug, unique: true



    create_table :hancock_pages_pages do |t|
      t.boolean :enabled, default: true, null: false

      t.references :hancock_connectable, polymorphic: true, index: {name: :index_hancock_pages_page_on_hancock_connectable}

      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth

      if Hancock.config.localize
        if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
          t.json :name_translations, default: {}
          t.json :content_html_translations, default: {}
          t.json :content_clear_translations, default: {}
          t.json :excerpt_html_translations, default: {}
          t.json :excerpt_clear_translations, default: {}
        else
          t.column :name_translations, 'hstore', default: {}
          t.column :content_html_translations, 'hstore', default: {}
          t.column :content_clear_translations, 'hstore', default: {}
          t.column :excerpt_html_translations, 'hstore', default: {}
          t.column :excerpt_clear_translations, 'hstore', default: {}
        end
      else
        t.string :name, null: false
        t.text :content_html, default: ""
        t.boolean :content_clear, default: false, null: false
        t.text :excerpt_html, default: ""
        t.boolean :excerpt_clear, default: false, null: false
      end

      t.string :layout_name, default: "application"

      t.string :slug, null: false
      t.string :regexp
      t.string :redirect
      t.string :fullpath, null: false

      t.string :subdomain, null: false, default: ""



      t.boolean :use_wrapper, default: false, null: false
      t.string :wrapper_tag, default: ""
      t.string :wrapper_class, default: ""
      t.string :wrapper_id, default: ""
      if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
        t.json :wrapper_attributes
      else
        t.column :wrapper_attributes, 'hstore', default: {}
      end


      t.timestamps
    end
    add_index :hancock_pages_pages, :slug, unique: true
    add_index :hancock_pages_pages, [:enabled, :lft]


    ######### pages <-> menus join table #############

    create_join_table :hancock_pages_menus, :hancock_pages_pages, table_name: :hancock_pages_menu_pages

    add_foreign_key(:hancock_pages_menu_pages, :hancock_pages_menus, dependent: :delete)
    add_foreign_key(:hancock_pages_menu_pages, :hancock_pages_pages, dependent: :delete)
  end
end
