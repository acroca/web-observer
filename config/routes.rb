WebObserver::Application.routes.draw do
  root to: 'petitions#index'
  resources :petitions
end
