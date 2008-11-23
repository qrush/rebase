class EventsController < ApplicationController
  
  def index
    c = Chartify.new

    @weekly_chart = c.line_chart("Weekly Chart", Event.max_daily_commits) do |chart|
      colors = ["000000", "ff0000","00ff00", "0000ff", "FFFF00", "3CB371", "ff00ff", "FF9900", "FFFF99", "993399"]
      
      Event.kinds.each_with_index do |kind, i|
        chart.data kind, Event.count(:group => 'date(published)', :conditions => ["kind = ?", kind]).map(&:last), colors[i]
      end
    end

    @total_chart = c.pie_chart("Total Events") do |chart|
      total_count = Event.count
      Event.count(:group => :kind).sort_by(&:last).reverse.each do |group|
        chart.data "#{group.first}: #{group.last}", (group.last.to_f / total_count.to_f) * 100
      end
    end

    @daily_chart = c.line_chart("Daily Events", Event.max_daily_events) do |chart|
      chart.show_legend = false
      chart.data "", Event.count(:group => 'date(published)').map(&:last), '336699'
    end

    @hourly_chart = c.line_chart("Hourly Events", Event.hourly_events.max) do |chart|
      chart.show_legend = false
      chart.data "", Event.hourly_events, '336699'
=begin      
      lc.axis :x, :labels =>
        @daily_grouped.map(&:first).map(&:to_datetime).map(&:wday).map { |d|
          Date::DAYNAMES[d][0..1]
        }.map{ |d| [d, 6, 12, 18] }.flatten
=end
    end
    
    @event_meter = c.meter_chart("GitHub-o-Meter", Event.count / (7 * 24 * 60).to_f.round(3))
    
  end
  
  def show
    @event = Event.find(params[:id])
  end
  
  def create
    redirect_to events_path
  end
  
  def edit
    @event = Event.find(params[:id])
  end
  
  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash[:notice] = "Successfully updated event."
      redirect_to @event
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    if params[:id].to_i > 0
      @event = Event.find(params[:id])
      @event.destroy
      flash[:notice] = "Successfully destroyed event."
    else
      Event.delete_all
      flash[:notice] = "Successfully destroyed all events."
    end
    
    redirect_to events_url
  end
  
  protected
    def convert_date(key)
      q = params[:events]
      
      return Date.new(q["#{key}(1i)"].to_i, q["#{key}(2i)"].to_i, q["#{key}(3i)"].to_i)    
    end
  
end
