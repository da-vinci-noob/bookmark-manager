class CreateBookmarkTags < ActiveRecord::Migration[8.0]
  def change
    create_table :bookmark_tags do |t|
      t.references :bookmark, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :bookmark_tags, [:bookmark_id, :tag_id], unique: true
  end
end
