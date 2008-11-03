class ReposController < ApplicationController
  def index
    @repos = Repo.find(:all, :order => 'watchers desc')
  end
  
  def show
    @repo = Repo.find(params[:id])
  end
  
  def commits
    Event.find_all_by_kind("commit").each do |event|

      title = event.title.split('/').last
      repo = Repo.find_by_title(title)
      
      unless repo
        url = "http://github.com/#{event.author}/#{title}"
        repo = parse_repo(event.id, title, url)
      end
      
      repo.increment!(:commits)
    end
    
    redirect_to repos_path
  end

  def create
    Event.find_all_by_kind("create").each do |event|
      next if Repo.exists?(:event_id => event.id)
      
      url = (Hpricot(event.message)/"a").attr("href")
      
      parse_repo(event.id, event.title.split.last, url)
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
  
  protected 
    def parse_repo(event_id, title, url) 
      begin
        nodes = (Hpricot(open(url))/".site ul a")
      rescue OpenURI::HTTPError => e
        logger.info "Document is not accessible: #{url}"
      rescue RuntimeError => e
        logger.info "Document is not public: #{url}"
      end

      if nodes && !nodes.empty? 
        r = Repo.new
        r.event_id = event_id
        r.title = title
        r.wiki = nodes[3].innerHTML.scan(/\d+/).first
        r.watchers = nodes[4].innerHTML.scan(/\d+/).first
        r.network = nodes[5].innerHTML.scan(/\d+/).first
        r.save
      end
      
      return r
    end
end
