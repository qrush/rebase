class EventsController < ApplicationController
  
  def index
=begin

    graph_size = "530x375"
    
    @events = Event.find_all_by_kind(params[:kind]) if params[:kind]
    @total_grouped = Event.count(:group => :kind).sort_by(&:last).reverse
    @daily_grouped = Event.count(:group => 'date(published)')
    @hourly_grouped = Event.count(:group => "strftime('%m-%d-%Y %H', published)")
    @event_count = Event.count / (7 * 24 * 60).to_f.round(3)
    @total_count = Event.count
    
    return if @daily_grouped.empty?
    
    start_date = DateTime.parse(@daily_grouped.first.first).to_formatted_s(:date)
    stop_date = DateTime.parse(@daily_grouped.last.first).to_formatted_s(:date)
    
    title = lambda { |t| "GitHub Rebase — #{t} — #{start_date} to #{stop_date}" }
    y_axis = {:color => '000000', :font_size => 10, :alignment => :right}

    @weekly_chart = GoogleChart::LineChart.new(graph_size, title.call("Weekly Events"), false) { |lc|
      
      lc.fill_area 'bbccd9', 0, 0 

      Event.kinds.each do |kind|
       lc.data kind, Event.count(:group => 'date(published)', :conditions => ["kind = ?", kind]).map(&:last)
      end

#      lc.max_value 10 # Setting max value for simple line chart 
      #lc.range_marker :horizontal, :color => 'E5ECF9', :start_point => 0.1, :end_point => 0.5
      #lc.range_marker :vertical, :color => 'a0bae9', :start_point => 0.1, :end_point => 0.5
      # Draw an arrow shape marker against lowest value in dataset
      #lc.shape_marker :arrow, :color => '000000', :data_set_index => 0, :data_point_index => 3, :pixel_size => 10   
    }.to_url

    
    @total_chart = GoogleChart::PieChart.new("530x220", title.call("Total Events"), false) { |pc|
      
      @total_grouped.each do |group|
        pc.data "#{group.first}: #{group.last}", (group.last.to_f / @total_count.to_f) * 100
      end
      pc.fill_area 'bbccd9', 0, 0
      pc.is_3d = true
      pc.fill :background, :solid, :color => 'f0f0f0'
      
    }.to_url(:chco => '336699')
    
    @daily_chart = GoogleChart::LineChart.new(graph_size, title.call("Daily Events"), false) { |lc|
      lc.show_legend = false
      lc.data "", @daily_grouped.map(&:last), '336699'
      lc.fill_area 'bbccd9', 0, 0 
      lc.axis :x, :labels => 
        @daily_grouped.map{|g| g.first.to_datetime.to_formatted_s(:date_small)}, :color => '4183c4', :font_size => 9, :alignment => :right
      lc.axis :y, y_axis.merge(:range => [0,4500])
      lc.fill :background, :solid, :color => 'f0f0f0'
    }.to_url
    
    @hourly_chart = GoogleChart::LineChart.new(graph_size, title.call("Hourly Events"), false) { |lc|
      lc.show_legend = false
      lc.data "", @hourly_grouped.map(&:last), '336699'
      lc.fill_area 'bbccd9', 0, 0 
      
      lc.axis :x, :labels =>
        @daily_grouped.map(&:first).map(&:to_datetime).map(&:wday).map { |d|
          Date::DAYNAMES[d][0..1]
        }.map{ |d| [d, 6, 12, 18] }.flatten
      
      lc.axis :y, y_axis.merge(:range => [0,@hourly_grouped.map(&:last).max])
      lc.fill :background, :solid, :color => 'f0f0f0'
    }.to_url

    @event_meter = GoogleChart::PieChart.new('400x175', "", false).to_url(
      :cht => "gom", :chd => "t:#{@event_count * 10}", :chl => "#{@event_count.round(2)} events/min")
=end 
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
