Rails.application.routes.draw do
  resources :shows
  resources :show_searches, only: [:new, :create] 
end
