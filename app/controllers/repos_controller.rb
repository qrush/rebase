class ReposController < ApplicationController
  def index
    @repos = Repo.find(:all)
  end
  
  def show
    @repo = Repo.find(params[:id])
  end
  
  
  def create
    Event.find_all_by_kind("create").each do |event|
      next if Repo.exists?(:event_id => event.id)
      
      url = (Hpricot(event.message)/"a").attr("href")
      
      begin
        nodes = (Hpricot(open(url))/".site ul a")
      rescue OpenURI::HTTPError => e
        logger.info "Document is not accessible: #{url}"
      rescue RuntimeError => e
        logger.info "Document is not public: #{url}"
      end
      
      if nodes && !nodes.empty? 
        r = Repo.new
        r.event_id = event.id
        r.wiki = nodes[3].innerHTML.scan(/\d+/).first
        r.watchers = nodes[4].innerHTML.scan(/\d+/).first
        r.network = nodes[5].innerHTML.scan(/\d+/).first
        r.save
      end
    end  
    
    flash[:notice] = "Successfully parsed repos."
    redirect_to repos_path
  end
  
  def edit
    @repo = Repo.find(params[:id])
  end
  
  def update
    @repo = Repo.find(params[:id])
    if @repo.update_attributes(params[:repo])
      flash[:notice] = "Successfully updated repo."
      redirect_to @repo
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    if params[:id].to_i > 0
      @repo = Repo.find(params[:id])
      @repo.destroy
      flash[:notice] = "Successfully destroyed repo."
    else
      Repo.delete_all
      flash[:notice] = "Successfully destroyed all repos."
    end
    
    redirect_to repos_url
  end
end
