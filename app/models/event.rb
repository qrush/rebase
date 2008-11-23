class Event < ActiveRecord::Base
  has_one :repo
  belongs_to :forker

  validates_uniqueness_of :unique_id  

  def fill(entry)
    self.forker = Forker.find_or_create_by_name(entry.author.split.first)
    self.kind = entry.id.scan(/[A-Za-z]+Event/).first.gsub("Event", "").downcase
    self.unique_id = entry.id.scan(/\d+$/).first
    self.title = entry.title
    self.message = entry.content
  end
end
