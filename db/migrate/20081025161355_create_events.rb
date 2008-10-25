class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :kind
      t.string :author
      t.datetime :published
      t.text :message
      t.string :title
      t.timestamps
    end
  end
  
  def self.down
    drop_table :events
  end
end
