namespace :rebase do
  desc "Parse out!"
  task :parse => :environment do
    page = ENV['page'] ? ENV['page'].to_i : 1
    stop = Date.today.to_datetime
    start = stop - 1.week
    parsing = true

    while parsing
      begin
        RAILS_DEFAULT_LOGGER.info "Parsing page #{page}"
        feed = FeedNormalizer::FeedNormalizer.parse open("#{TIMELINE_ROOT}/#{page}.atom")
      rescue Exception => e
        RAILS_DEFAULT_LOGGER.info "Problem parsing the feed: #{e}"
      end
      
      if( parsing = (feed && !feed.entries.empty?) )
        feed.entries.each do |entry|
          next if entry.nil? || entry.is_a?(String)

          event = Event.new(:published => entry.date_published.to_datetime)

          if event.published >= start && event.published <= stop
            event.fill(entry)
            event.save
          elsif event.published < start
            parsing = false
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
        open("#{TIMELINE_ROOT}/#{start}.atom", "wb") do |file|
          file.write(resp.body)
        end

        start += ENV['step'].to_i
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

  desc "Nuke everything."
  task :nuke => ["rebase:nuke_timeline", "rebase:nuke_events"]

  desc "Rip the feeds."
  task :rip do
    threads = 5
    threads.times do |i|
      Kernel.fork { `rake rebase:download start=#{i+1} stop=#{ENV['stop']} step=#{threads}` }
    end
  end

  desc "Throw out any error pages"
  task :throwout => :environment do
    (1..ENV['stop'].to_i).each do |i|
      delete = false
      path = "#{TIMELINE_ROOT}/#{i}.atom"
      open(path, "r") { |f| delete = true unless f.readline =~ /^<\?xml/ }
      FileUtils.rm(path, :verbose => true) if delete
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
