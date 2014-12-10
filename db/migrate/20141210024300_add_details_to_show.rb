class AddDetailsToShow < ActiveRecord::Migration
  def change
    add_column :shows, :airs_day, :string
    add_column :shows, :airs_time, :string
    add_column :shows, :content_rating, :string
    add_column :shows, :airs_first, :date
    add_column :shows, :imdb_id, :string
    add_column :shows, :language, :string
    add_column :shows, :rating, :decimal
    add_column :shows, :rating_count, :integer
    add_column :shows, :runtime, :integer
    add_column :shows, :status, :string
    add_column :shows, :banner, :string
    add_column :shows, :fanart, :string
    add_column :shows, :poster, :string
    add_column :shows, :last_updated, :date
    add_column :shows, :genre, :text, array: true, default: []
    add_column :shows, :season_posters, :text, array: true, default: []
  end
end
