Rails.application.routes.draw do
  namespace :admin do
    resources :sports
  end
end
