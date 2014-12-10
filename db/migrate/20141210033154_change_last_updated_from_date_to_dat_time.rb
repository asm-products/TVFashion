class ChangeLastUpdatedFromDateToDatTime < ActiveRecord::Migration
def self.up
    change_table :shows do |t|
      t.change :last_updated, :datetime
    end
  end
  def self.down
    change_table :shows do |t|
      t.change :last_updated, :date
    end
  end
end
