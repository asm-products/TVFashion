class ChangeAiredFromStringToDate < ActiveRecord::Migration
  def self.up
    change_table :episodes do |t|
      t.remove :aired
      t.date :aired
    end
  end
  def self.down
    change_table :episodes do |t|
      t.remove :aired
      t.string :aired
    end
  end
end
