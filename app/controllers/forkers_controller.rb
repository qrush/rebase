class ForkersController < ApplicationController
  def index
    @forkers = Forker.find(:all)
  end
  
  def show
    @forker = Forker.find(params[:id])
  end
  
  def new
    @forker = Forker.new
  end
  
  def create
    @forker = Forker.new(params[:forker])
    if @forker.save
      flash[:notice] = "Successfully created forker."
      redirect_to @forker
    else
      render :action => 'new'
    end
  end
  
  def edit
    @forker = Forker.find(params[:id])
  end
  
  def update
    @forker = Forker.find(params[:id])
    if @forker.update_attributes(params[:forker])
      flash[:notice] = "Successfully updated forker."
      redirect_to @forker
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @forker = Forker.find(params[:id])
    @forker.destroy
    flash[:notice] = "Successfully destroyed forker."
    redirect_to forkers_url
  end
end