require 'active_record'


class Event < ActiveRecord::Base
	def self.kinds
		all(:group => :kind, :select => :kind).map(&:kind)
	end
end

ActiveRecord::Base.logger = Logger.new(STDOUT) if 'irb' == $0
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => DB)
ActiveRecord::Migration.verbose = false
