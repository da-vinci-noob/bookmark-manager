class CreateBookmarksTags < ActiveRecord::Migration[8.0]
  def change
    create_table :bookmarks_tags, id: false do |t|
      t.belongs_to :bookmark
      t.belongs_to :tag
    end

    add_index :bookmarks_tags, [:bookmark_id, :tag_id], unique: true
  end
end
