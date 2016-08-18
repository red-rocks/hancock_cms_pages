class HancockPagesCreateBlocks < ActiveRecord::Migration
  def change
    create_table :hancock_pages_blocksets do |t|

      if Hancock.config.localize
        t.column :name_translations, 'hstore'
      else
        t.string :name, null: false
      end
      t.string :slug, null: false
      t.timestamps
    end
    add_index :hancock_pages_blocksets, :slug, unique: true

    create_table :hancock_pages_blocks do |t|
      t.boolean :enabled, default: true, null: false
      
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth

      if Hancock.config.localize
        t.column :name_translations, 'hstore', default: {}
        t.column :content_html_translations, 'hstore', default: {}
        t.column :content_clear_translations, 'hstore', default: {}
      else
        t.string :name, null: false
        t.text :content
      end

      t.string :slug, null: false
      t.string :regexp
      t.string :redirect
      t.string :fullpath, null: false
      t.timestamps
    end
    add_index :hancock_pages_pages, :slug, unique: true
    add_index :hancock_pages_pages, [:enabled, :lft]

  end
end
