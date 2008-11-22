class Event < ActiveRecord::Base
  has_one :repo
  belongs_to :forker

  def fill(entry)
    logger.info "Filling out stuff..."

    self.forker = Forker.find_or_create_by_name(entry.author.split.first)
    self.kind = entry.id.scan(/[A-Za-z]+Event/).first.gsub("Event", "").downcase
    self.title = entry.title
    self.message = entry.content

    logger.info "Yay: #{self.inspect}"
  end

  class << self
    def parse(start, stop, page = 1)
      parsing = true
      
      while parsing
        feed = self.get(page)
        
        if( parsing = (feed && !feed.entries.empty?) )
logger.info "This feed: #{feed.entries.size}"      
          feed.entries.each do |entry|
            next if entry.nil? || entry.is_a?(String)

            event = Event.new(:published => entry.date_published.to_datetime)
            
            logger.info "New event is at: #{event.published}"
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
