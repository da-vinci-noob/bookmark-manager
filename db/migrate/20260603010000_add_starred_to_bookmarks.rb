class AddStarredToBookmarks < ActiveRecord::Migration[8.1]
  def change
    add_column :bookmarks, :starred, :boolean, default: false, null: false
  end
end
