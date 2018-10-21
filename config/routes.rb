Rails.application.routes.draw do

  root :to => 'works#home'

  devise_for :users, controllers: { registrations: 'registrations' }
  get "users/:id/collection" => "users#collection"
  get "users/:id/profile" => "users#profile"
  get 'users/user' => "users#user"
  get 'users/ajax_user_list' => "users#ajax_user_list"
  get 'users/configuration' => "users#configuration"

  resources :users do
    member do
     get :following, :followers
    end
  end
  resources :relationships,       only: [:create, :destroy]

  get 'works/index' => "works#index"
  get 'works/category' => "works#category"
  get 'works/search' => "works#search"
  get 'works/movie' => "works#movie"
  get 'works/movie/detail' => "works#movie_detail"
  get 'works/ajax_movie_list' => "works#ajax_movie_list"
  get 'works/book' => "works#book"
  get 'works/book/detail' => "works#book_detail"
  get 'works/ajax_book_list' => "works#ajax_book_list"
  get 'works/music' => "works#music"
  get 'works/music/detail' => "works#music_detail"
  get 'works/ajax_music_list' => "works#ajax_music_list"
  post 'works/save' => "works#save"
  get "works/:id/detail" => "works#detail"
  get "works/:id/edit" => "works#edit"
  get "works/:id/copy" => "works#copy"
  post "works/:id/update" => "works#update"
  post "works/:id/destroy" => "works#destroy"

  get 'works/test' => "works#test"

  post "likes/:post_id/create" => "likes#create"
  post "likes/:post_id/destroy" => "likes#destroy"
end
