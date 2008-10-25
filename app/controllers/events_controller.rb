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
    feed = FeedNormalizer::FeedNormalizer.parse open('http://github.com/timeline.atom')
    feed.clean!
    
    feed.entries.each do |entry|
      event = Event.new
      event.kind = entry.id.scan(/[A-Za-z]+Event/).first.gsub("Event", "").downcase
      event.published = entry.date_published
      event.author = entry.author.split.first
      event.title = entry.title
      event.message = entry.content
      event.save
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
    @event = Event.find(params[:id])
    @event.destroy
    flash[:notice] = "Successfully destroyed event."
    redirect_to events_url
  end
end
