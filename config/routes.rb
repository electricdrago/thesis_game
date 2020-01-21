Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'player_pages#home'
  get 'home' => 'player_pages#home'
  post 'sign_in' => 'users#signin'

end
