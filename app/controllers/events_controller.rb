require 'feed-normalizer'

class EventsController < ApplicationController
  
  def index
    
    @events = Event.find_all_by_kind(params[:kind]) if params[:kind]
    @total_grouped = Event.count(:group => :kind).sort_by(&:last).reverse
    @daily_grouped = Event.count(:group => 'date(published)')
    @event_count = Event.count / (7 * 24 * 60).to_f.round(3)
    
    start_date = @daily_grouped.first.first
    stop_date = @daily_grouped.last.last
    
    title = lambda { |t| "GitHub Rebase — #{t} — #{start_date} to #{stop_date}" }
    y_axis = {:color => '000000', :font_size => 10, :alignment => :right}
    
    @total_chart = GoogleChart::BarChart.new('530x375', title.call("Total Events"), :horizontal, false) { |bc| 
      bc.data "", @total_grouped.map(&:last), '336699'
      bc.show_legend = false 
      bc.axis :y, :labels => @total_grouped.map{|g| "#{g.first} (#{g.last})"}.reverse, :color => '4183c4', :font_size => 10, :alignment => :right
      bc.axis :x, :range => [0,15000], :color => '000000', :font_size => 10, :alignment => :center
      bc.width_spacing_options :bar_width => 22, :bar_spacing => 2
      bc.fill :background, :solid, :color => 'f0f0f0'
    }.to_url
    
    @daily_chart = GoogleChart::LineChart.new('530x375', title.call("Daily Events"), false) { |lc|
      lc.show_legend = false
      lc.data "", @daily_grouped.map(&:last), '336699'
      lc.fill_area 'bbccd9', 0, 0 
      lc.axis :x, :labels => @daily_grouped.map{|g| g.first.to_datetime.to_formatted_s(:date_small)}, :color => '4183c4', :font_size => 9, :alignment => :right
      lc.axis :y, y_axis.merge(:range => [0,4500])
      lc.fill :background, :solid, :color => 'f0f0f0'
    }.to_url

    @event_meter = GoogleChart::PieChart.new('400x175', "", false).to_url(:cht => "gom", :chd => "t:#{@event_count * 10}", :chl => "#{@event_count.round(2)} events/min")
  end
  
  def show
    @event = Event.find(params[:id])
  end
  
  def create
    if Event.count > 0
      flash[:error] = "Whoa, don't parse again. Nuke first, ask questions later."
      redirect_to events_path and return
    end
    
    page = 1
    parse = true
    start_date = convert_date('start_date')
    stop_date = convert_date('stop_date')
    
    parse_feed = lambda do |p|   
      begin
        logger.info "Parsing page #{p}"
        FeedNormalizer::FeedNormalizer.parse open("http://github.com/timeline.atom?page=#{p}")
      rescue Exception => e
        logger.info "Problem parsing the feed: #{e}"
      end
    end
    
    while parse
      feed = parse_feed.call(page)
      
      if( parse = (feed && !feed.entries.empty?) )
        feed.entries.each do |entry|
          event = Event.new
          event.published = entry.date_published.to_datetime
          
          if event.published >= start_date && event.published <= stop_date
            event.kind = entry.id.scan(/[A-Za-z]+Event/).first.gsub("Event", "").downcase
            event.author = entry.author.split.first
            event.title = entry.title
            event.message = entry.content
            event.save
          elsif event.published < start_date
            parse = false
            break
          end
        end
      end
      
      page = page + 1
    end
    
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
