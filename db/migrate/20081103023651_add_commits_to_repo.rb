class AddCommitsToRepo < ActiveRecord::Migration
  def self.up
    add_column :repos, :commits, :integer
  end

  def self.down
    remove_column :repos, :commits
  end
end
