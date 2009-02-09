DB = 'rebase.db'
START_DATE = DateTime.parse("2009-02-01")
END_DATE = DateTime.parse("2009-02-07 23:59:59")

require 'event'
require 'chartify'
require 'launchy'
require 'feedzirra'

namespace :db do
	desc "Drop db"
	task :drop do
		File.delete(DB) if File.exists?(DB)
	end

	desc "Create dbs"
	task :create do
		ActiveRecord::Schema.define(:version => 1) do
			create_table 'events' do |t|
				t.string :kind
				t.string :user
				t.datetime :published
			end
		end
	end

	desc "Reset db"
	task :reset => [:drop, :create]
end

namespace :chart do
	desc "Events pie"
	task :pie do
		c = Chartify.new(START_DATE, END_DATE)

		url = c.pie_chart("Total Events") do |chart|
			total_count = Event.count
			Event.count(:group => :kind).sort_by(&:last).reverse.each do |group|
				chart.data "#{group.first}: #{group.last}", (group.last.to_f / total_count.to_f) * 100
			end
		end

		IO.popen('pbcopy', 'w').print url
	end

	desc "Events line breakdown"
	task :line do
		c = Chartify.new(START_DATE, END_DATE)

		url = c.line_chart("Events Breakdown", Event.max_daily_commits) do |chart|
			colors = %w(000000 ff0000 00ff00 0000ff FFFF00 3CB371 ff00ff FF9900 FFFF99 993399)

			Event.kinds.each_with_index do |kind, i|
				if Event.count(:conditions => ["kind = ?", kind]) > 500

					chart.data kind, 
										 Event.count(:group => "strftime('%m-%d-%Y %H', published)", 
																 :conditions => ["kind = ?", kind]).map(&:last), 
										 colors.shift
				end
			end
		end

		IO.popen('pbcopy', 'w').print url
	end
 end

desc "Parse away"
task :parse do
	urls = []
	(275..3150).each { |x| urls << "http://github.com/timeline.atom?page=#{x}" }

	Feedzirra::Feed.fetch_and_parse(urls, 
		:on_success => lambda {|u, a| puts "Got #{u}"} ).each do |k, v|

		if v.is_a?(Fixnum)
			puts "\nBroken page: #{k}"
			next
		else
			puts "\nWorking on #{k}, #{v.entries.size} entries..."
		end

		v.entries.each do |entry|
			next unless START_DATE < entry.published && entry.published < END_DATE

			e = Event.new
			e.user = entry.author
			e.published = entry.published

			title = entry.title.split
			e.type = title[1]
			e.save
			puts e
		end
	end
end
