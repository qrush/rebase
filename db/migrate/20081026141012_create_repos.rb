class CreateRepos < ActiveRecord::Migration
  def self.up
    create_table :repos do |t|
      t.integer :event_id
      t.integer :watchers
      t.integer :network
      t.integer :wiki
      t.timestamps
    end
  end
  
  def self.down
    drop_table :repos
  end
end
