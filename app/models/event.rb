require 'net/http'

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

  class << self
    def parse(start, stop, page = 1)

      parsing = true
      
      while parsing
        feed = self.get(page)
        
        if( parsing = (feed && !feed.entries.empty?) )
          feed.entries.each do |entry|
            next if entry.nil? || entry.is_a?(String)

            event = Event.new(:published => entry.date_published.to_datetime)
            
            if event.published >= start && event.published <= stop
              event.fill(entry)
              event.save
            elsif event.published < start
              parse = false
              break
            end
          end
        end
        
        page += 1
      end
    end
  
    def get(page)
      begin
        logger.info "Parsing page #{page}"
        FeedNormalizer::FeedNormalizer.parse open("http://github.com/timeline.atom?page=#{page}")
      rescue Exception => e
        logger.info "Problem parsing the feed: #{e}"
      end
    end

  end
end
