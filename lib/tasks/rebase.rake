namespace :rebase do
  desc "Parse out!"
  task :parse => :environment do
   
    page = 100
    start = Date.today.to_datetime
    stop = start - 1.week
    parsing = true

    while parsing
      begin
        p "Parsing page #{page}"
        feed = FeedNormalizer::FeedNormalizer.parse open("#{TIMELINE_ROOT}/#{page}.atom")
      rescue Exception => e
        p "Problem parsing the feed: #{e}"
      end
      
      if( parsing = (feed && !feed.entries.empty?) )
        feed.entries.each do |entry|
          next if entry.nil? || entry.is_a?(String)

          event = Event.new(:published => entry.date_published.to_datetime)

          if event.published >= start && event.published <= stop
            event.fill(entry)
            return
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
  


  desc "Download timeline feeds from GitHub"
  task :download  => :environment do
    require 'net/http'
    page = 1
    stop = ENV['stop'].to_i
    start = ENV['start'].to_i
  
    Net::HTTP.start("github.com") do |http|
      while start <= stop

        puts "Downloading page #{start}"

        resp = http.get("/timeline.atom?page=#{start}")
        open("#{RAILS_ROOT}/db/timeline/#{start}.atom", "wb") do |file|
          file.write(resp.body)
        end

        start += 3
      end
    end
  end

  desc "Get rid of the files in db/timeline"
  task :nuke_timeline do
    FileUtils.rm_r Dir.glob(TIMELINE_GLOB)
  end

  desc "Get rid of events"
  task :nuke_events => :environment do
    Event.delete_all
  end

  desc "Rip the feeds."
  task :rip do
    3.times do |i|
      Kernel.fork { `rake rebase:download start=#{i+1} stop=#{ENV['stop']}` }
    end
  end

  desc "Look up the leftovers."
  task :leftovers => :environment do
    stop = ENV['stop'].to_i
    real = (1..stop).to_a.sort
    current = Dir.glob(TIMELINE_GLOB).map{|f| f.scan(/\d+/).first.to_i}.sort

    p (real - current)
  end

end
