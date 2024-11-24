# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_11_24_202911) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.string "url", null: false
    t.string "title", null: false
    t.text "description"
    t.string "thumbnail_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url"], name: "index_bookmarks_on_url"
  end

  create_table "bookmarks_tags", id: false, force: :cascade do |t|
    t.bigint "bookmark_id"
    t.bigint "tag_id"
    t.index ["bookmark_id", "tag_id"], name: "index_bookmarks_tags_on_bookmark_id_and_tag_id", unique: true
    t.index ["bookmark_id"], name: "index_bookmarks_tags_on_bookmark_id"
    t.index ["tag_id"], name: "index_bookmarks_tags_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
