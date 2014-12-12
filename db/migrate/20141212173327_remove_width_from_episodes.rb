class RemoveWidthFromEpisodes < ActiveRecord::Migration
  def up
    remove_column :episodes, :width
  end

  def down
    add_column :episodes, :width, :string
  end
end
