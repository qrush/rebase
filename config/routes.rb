ActionController::Routing::Routes.draw do |map|
  map.resources :repos
  map.resources :events
  map.root :controller => 'events'
end
