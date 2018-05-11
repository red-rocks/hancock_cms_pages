class HancockPagesCreateBlocks < ActiveRecord::Migration[5.1]
  def change
    create_table :hancock_pages_blocksets do |t|

      t.references :blocks, table_name: :hancock_pages_blocks

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
    add_index :hancock_pages_blocksets, :slug, unique: true



    create_table :hancock_pages_blocks do |t|
      t.boolean :enabled, default: true, null: false

      t.belongs_to :blockset, null: false, table_name: :hancock_pages_blocksets, index: true


      t.boolean :partial, default: true
      t.boolean :render_file, default: true

      if Hancock.config.localize
        if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
          t.json :pageblock_selector_translations, default: {}
          t.json :file_path_translations, default: {}
        else
          t.column :pageblock_selector_translations, 'hstore', default: {}
          t.column :file_path_translations, 'hstore', default: {}
        end
      else
        t.string :pageblock_selector, default: ""
        t.string :file_path, default: ""
      end


      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth

      if Hancock.config.localize
        if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
          t.json :name_translations, default: {}
          t.json :content_html_translations, default: {}
          t.json :content_clear_translations, default: {}
        else
          t.column :name_translations, 'hstore', default: {}
          t.column :content_html_translations, 'hstore', default: {}
          t.column :content_clear_translations, 'hstore', default: {}
        end
      else
        t.string :name, null: false
        t.text :content_html, default: ""
        t.boolean :content_clear, default: false, null: false
      end


      t.boolean :use_wrapper, default: false
      t.string :wrapper_tag, default: ""
      t.string :wrapper_class, default: ""
      t.string :wrapper_id, default: ""
      if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
        t.json :wrapper_attributes
      else
        t.column :wrapper_attributes, 'hstore', default: {}
      end

      t.string :menu_link_content, default: ""
      t.boolean :show_in_menu, default: true

      t.timestamps
    end
    add_index :hancock_pages_blocks, [:enabled, :lft]

  end
end
