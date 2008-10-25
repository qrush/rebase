require 'feed-normalizer'
require 'open-uri'

class EventsController < ApplicationController
  def index
    @groups = Event.count(:group => :kind)
    
    if params[:kind]
      @events = Event.find_all_by_kind(params[:kind])
    end
  end
  
  def show
    @event = Event.find(params[:id])
  end
  
  
  def create
    
    page = 1
    parse = true
    
    parse_feed = lambda do |p|   
      begin
        FeedNormalizer::FeedNormalizer.parse open("http://github.com/timeline.atom?page=#{p}")
      rescue Exception => e
        logger.info "Problem parsing the feed: #{e}"
      end
    end
    
    stop_date = Date.today.to_datetime
    start_date = stop_date - 1.week
    
    logger.info ">>>>>>>> Start: #{start_date} Stop: #{stop_date}"
    while parse
      feed = parse_feed.call(page)
      logger.info ">>>>>>>>> Parsing Page #{page}"
      
      if( parse = (feed && !feed.entries.empty?) )
        feed.entries.each do |entry|
          event = Event.new
          event.published =entry.date_published.to_datetime
          
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
end
