class Event < ActiveRecord::Base
  has_one :repo
  belongs_to :forker

  def fill(entry)
    forker = Forker.find_or_create_by_name(entry.author.split.first)
    kind = entry.id.scan(/[A-Za-z]+Event/).first.gsub("Event", "").downcase
    title = entry.title
    message = entry.content
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
            
            if event.published >= start_date && event.published <= stop_date
              event.fill(entry)
              event.save
            elsif event.published < start_date
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
        logger.info "Parsing page #{p}"
        FeedNormalizer::FeedNormalizer.parse open("http://github.com/timeline.atom?page=#{p}")
      rescue Exception => e
        logger.info "Problem parsing the feed: #{e}"
      end
    end

  end
end
