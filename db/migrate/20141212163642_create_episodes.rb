class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.string :tvdb_id
      t.integer :episode_number
      t.integer :season_number
      t.string :name
      t.string :aired
      t.string :imdb_id
      t.string :language
      t.text :overview
      t.float :rating
      t.integer :rating_count
      t.string :image
      t.integer :image_height
      t.integer :image_width
      t.integer :width
      t.string :season_id
      t.datetime :last_updated
      t.text :directors, array: true, default: []
      t.text :guest_stars, array: true, default: []
      t.text :writers, array: true, default: []
      t.references :show, index: true
      
      t.timestamps
    end
  end
end
