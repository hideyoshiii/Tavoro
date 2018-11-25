Rails.application.routes.draw do

  root :to => 'works#index'

  devise_for :users, controllers: { registrations: 'registrations' }

  get ":id/posts" => "users#posts"
  get 'users/follow_request' => "users#follow_request"
  get 'users/user' => "users#user"
  get 'users/ajax_user_list' => "users#ajax_user_list"
  get 'users/following' => "users#following"
  get 'users/ajax_following_list' => "users#ajax_following_list"
  get 'users/follower' => "users#follower"
  get 'users/ajax_follower_list' => "users#ajax_follower_list"
  get 'configuration' => "users#configuration"
  get 'users/ajax_validate_username' => "users#ajax_validate_username"
  get 'policy' => "users#policy"
  get 'terms' => "users#terms"
  get 'contact' => "users#contact"
  get 'notification' => "users#notification"
  get 'invitation' => "users#invitation"

  resources :users do
    member do
     get :following, :followers
    end
  end
  resources :relationships,       only: [:create, :destroy]

  resources :users do
    member do
     get :requesting, :requesters
    end
  end
  resources :follow_requests,       only: [:create, :destroy]

  post "follow_requests/:id/approval" => "follow_requests#approval"
  post "follow_requests/:id/unapproval" => "follow_requests#unapproval"

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

  post "works/:id/create_bookmark" => "works#create_bookmark"
  post "works/:id/destroy_bookmark" => "works#destroy_bookmark"

  post "works/:id/create_list" => "works#create_list"
  post "works/:id/destroy_list" => "works#destroy_list"

  get 'works/test' => "works#test"

  post "likes/:post_id/create" => "likes#create"
  post "likes/:post_id/destroy" => "likes#destroy"

  resources :invitations, only: [:create, :destroy]
  get 'invitation/:id' => "invitations#invite"


  get '*path', to: 'application#render_404'
end
