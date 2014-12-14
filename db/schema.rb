# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141212173514) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actors", force: true do |t|
    t.string   "name"
    t.string   "tvdb_id"
    t.string   "image"
    t.string   "role"
    t.integer  "sort_order"
    t.integer  "show_id"
    t.datetime "last_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "actors", ["show_id"], name: "index_actors_on_show_id", using: :btree

  create_table "episodes", force: true do |t|
    t.string   "tvdb_id"
    t.integer  "episode_number"
    t.integer  "season_number"
    t.string   "name"
    t.string   "imdb_id"
    t.string   "language"
    t.text     "overview"
    t.float    "rating"
    t.integer  "rating_count"
    t.string   "image"
    t.integer  "image_height"
    t.integer  "image_width"
    t.string   "season_id"
    t.datetime "last_updated"
    t.text     "directors",      default: [], array: true
    t.text     "guest_stars",    default: [], array: true
    t.text     "writers",        default: [], array: true
    t.integer  "show_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "aired"
  end

  add_index "episodes", ["show_id"], name: "index_episodes_on_show_id", using: :btree

  create_table "shows", force: true do |t|
    t.string   "name"
    t.text     "overview"
    t.string   "tvdb_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "airs_day"
    t.string   "airs_time"
    t.string   "content_rating"
    t.date     "airs_first"
    t.string   "imdb_id"
    t.string   "language"
    t.float    "rating"
    t.integer  "rating_count"
    t.integer  "runtime"
    t.string   "status"
    t.string   "banner"
    t.string   "fanart"
    t.string   "poster"
    t.datetime "last_updated"
    t.text     "genre",          default: [], array: true
    t.text     "season_posters", default: [], array: true
    t.string   "network"
  end

end
