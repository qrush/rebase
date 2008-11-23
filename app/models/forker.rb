class Forker < ActiveRecord::Base
  has_many :events do 
    def method_missing(m, *args)
      Event.count(:conditions => ['forker_id = ? and kind = ?', proxy_owner.id, m.to_s.singularize])
    end
  end

  def to_s
    name
  end
end
