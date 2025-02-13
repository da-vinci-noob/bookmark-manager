class AddUniqueIndexToBookmarksUrlAndUser < ActiveRecord::Migration[8.0]
  def change
    remove_index :bookmarks, :url if index_exists?(:bookmarks, :url)
    add_index :bookmarks, [:url, :user_id], unique: true
  end
end
