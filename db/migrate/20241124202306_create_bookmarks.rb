class CreateBookmarks < ActiveRecord::Migration[8.0]
  def change
    create_table :bookmarks do |t|
      t.string :url, null: false
      t.string :title, null: false
      t.text :description
      t.string :thumbnail_url

      t.timestamps
    end

    add_index :bookmarks, :url
  end
end
