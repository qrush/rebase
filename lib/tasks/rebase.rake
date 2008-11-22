namespace :rebase do
  desc "Download timeline feeds from GitHub"
  task :download do
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
  task :nuke do
    FileUtils.rm_r Dir.glob("#{RAILS_ROOT}/db/timeline/*")
  end

end
