Rails.application.routes.draw do

  root :to => 'works#index'

  devise_for :users, controllers: { registrations: 'registrations' }

  get ":id" => "users#posts"
  get 'users/user' => "users#user"
  get 'users/ajax_user_list' => "users#ajax_user_list"
  get ':id/following' => "users#following"
  get ':id/ajax_following_list' => "users#ajax_following_list"
  get ':id/follower' => "users#follower"
  get ':id/ajax_follower_list' => "users#ajax_follower_list"
  get 'users/configuration' => "users#configuration"
  get 'users/policy' => "users#policy"
  get 'users/terms' => "users#terms"
  get 'users/contact' => "users#contact"
  get 'users/notifications' => "users#notifications"
  get 'users/ajax_validate_username' => "users#ajax_validate_username"
  get 'users/follow_request' => "users#follow_request"

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

  get "post/:id" => "works#post"
  get 'works/movie' => "works#movie"
  get 'works/ajax_movie_list' => "works#ajax_movie_list"
  get 'works/book' => "works#book"
  get 'works/ajax_book_list' => "works#ajax_book_list"
  get 'works/music' => "works#music"
  get 'works/ajax_music_list' => "works#ajax_music_list"
  get 'works/new' => "works#new"
  get "works/:id/edit" => "works#edit"
  get "works/:id/copy" => "works#copy"
  post 'works/save' => "works#save"
  post "works/:id/update" => "works#update"
  post "works/:id/destroy" => "works#destroy"

  post "likes/:post_id/create" => "likes#create"
  post "likes/:post_id/destroy" => "likes#destroy"

  resources :invitations, only: [:create, :destroy]
  get 'invitation/:id' => "invitations#invitation"
  get 'invite' => "invitations#invite"

  get 'lists/setting/profile' => "lists#profile"
  post ":id/create_profile_sync" => "lists#create_profile_sync"
  post ":id/create_profile" => "lists#create_profile"
  post ":id/destroy_profile" => "lists#destroy_profile"
  post ":id/create_favorite" => "lists#create_favorite"
  post ":id/destroy_favorite" => "lists#destroy_favorite"

  get 'works/test' => "works#test"


  get '*path', to: 'application#render_404'
end
