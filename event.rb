require 'active_record'


class Event < ActiveRecord::Base
	class << self
		def kinds
			all(:group => :kind, :select => :kind).map(&:kind)
		end

		def max_daily_commits
			count(:group => 'date(published)', :conditions => "kind = 'committed'").map(&:last).max
		end
	end
end

ActiveRecord::Base.logger = Logger.new(STDOUT) if 'irb' == $0
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => DB)
ActiveRecord::Migration.verbose = false
