class AddForkersToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :forker_id, :integer
    remove_column :events, :author
  end

  def self.down
    remove_column :events, :forker_id
    add_column :events, :author, :string
  end
end
