class CreateForkers < ActiveRecord::Migration
  def self.up
    create_table :forkers do |t|
      t.string :name
      t.timestamps
    end
  end
  
  def self.down
    drop_table :forkers
  end
end
