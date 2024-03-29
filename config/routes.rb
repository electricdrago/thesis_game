Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'main_pages#home'
  get 'home' => 'main_pages#home'
  get 'sign_in' => 'users#signin'
  get 'logout' => 'users#destroy'

  post 'save_step' => 'player_pages#save_step'
  #get 'temp_game' => 'extra_pages#temp_game'
  get 'game' => 'player_pages#Jssp_game'
  get 'shop' => 'player_pages#shop'
  get 'activity_assignment' => 'player_pages#Jssp_game'
  get 'story' => 'player_pages#history'
  get 'temp_admin' => 'extra_pages#temp_admin'
  get 'add_problems' => 'admin#add_problems'
  post 'upload_JSSP' => 'admin#save_JSSP'
  post 'upload_story' => 'admin#save_story'
  post 'end_game' => 'player_pages#end_game'
  post 'read_story' => 'player_pages#readStory'
  post 'add_points' => 'player_pages#addPoints'
  get 'answer/:id' => 'player_pages#answer'


  get 'jssp_info/:id' => 'admin#jssp_info'
  get 'stories' => 'admin#stories'
  get 'addstories' => 'admin#addStories'
  get 'addjssps' => 'admin#add_jssps'

  get 'prepare' => "admin#makeData"
  get 'download' => "admin#getData"
  get 'email' => "admin#email"
  get 'clean' => "admin#cleanMemory"
  get 'delete_all' => "admin#deleteAll"
  get 'full_pack' => "admin#fullPack"
  get 'data' => "admin#data"
  get 'rawdata' => "admin#raw_data"

end
