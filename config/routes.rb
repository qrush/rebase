ActionController::Routing::Routes.draw do |map|
  map.resources :forkers

  map.resources :repos, :collection => { :commits => :get }
  map.resources :events
  map.root :controller => 'events'
end
