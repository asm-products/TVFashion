class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.string :name
      t.text :overview
      t.string :tvdb_id

      t.timestamps
    end
  end
end
