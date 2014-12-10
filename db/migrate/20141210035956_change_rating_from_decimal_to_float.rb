class ChangeRatingFromDecimalToFloat < ActiveRecord::Migration
def self.up
    change_table :shows do |t|
      t.change :rating, :float
    end
  end
  def self.down
    change_table :shows do |t|
      t.change :rating, :decimal
    end
  end
end