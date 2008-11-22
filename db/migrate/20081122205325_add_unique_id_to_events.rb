class AddUniqueIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :unique_id, :integer
  end

  def self.down
    remove_column :events, :unique
  end
end
