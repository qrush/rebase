DB = 'rebase.db'
require 'active_record'
require 'feedzirra'

class Event < ActiveRecord::Base
end

ActiveRecord::Base.logger = Logger.new(STDOUT) if 'irb' == $0
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => DB)
ActiveRecord::Migration.verbose = false

namespace :db do
	desc "Drop db"
	task :drop do
		File.delete(DB) if File.exists?(DB)
	end

	desc "Create dbs"
	task :create do
		ActiveRecord::Schema.define(:version => 1) do
			create_table 'events' do |t|
				t.string :type
				t.string :user
				t.datetime :published
			end
		end
	end

	desc "Reset db"
	task :reset => [:drop, :create]
end

desc "Parse away"
task :parse do
	urls = []
	(275..3150).each { |x| urls << "http://github.com/timeline.atom?page=#{x}" }

	start_date = DateTime.parse("2009-02-01")
	end_date = DateTime.parse("2009-02-07 23:59:59")

	Feedzirra::Feed.fetch_and_parse(urls, 
		:on_success => lambda {|u, a| puts "Got #{u}"} ).each do |k, v|

		if v.is_a?(Fixnum)
			puts "\nBroken page: #{k}"
			next
		else
			puts "\nWorking on #{k}, #{v.entries.size} entries..."
		end

		v.entries.each do |entry|
			next unless start_date < entry.published && entry.published < end_date

			e = Event.new
			e.user = entry.author
			e.published = entry.published

			title = entry.title.split
			e.type = title[1]
			e.save
			p e
		end
	end
end
