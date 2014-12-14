class CreateActors < ActiveRecord::Migration
  def change
    create_table :actors do |t|
      t.string :name
      t.string :tvdb_id
      t.string :image
      t.string :role
      t.integer :sort_order
      t.references :show, index: true
      t.datetime :last_updated

      t.timestamps
    end
  end
end
