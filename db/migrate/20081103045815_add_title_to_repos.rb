class AddTitleToRepos < ActiveRecord::Migration
  def self.up
    add_column :repos, :title, :string
  end

  def self.down
    remove_column :repos, :title
  end
end
