Rails.application.routes.draw do

  root :to => 'works#index'

  devise_for :users, controllers: { registrations: 'registrations' }

  get ":id/posts" => "users#posts"
  get ":id/bookmarks" => "users#bookmarks"
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
  get 'works/ajax_movie_list' => "works#ajax_movie_list"
  get 'works/movie/detail' => "works#movie_detail"
  get 'works/book' => "works#book"
  get 'works/ajax_book_list' => "works#ajax_book_list"
  get 'works/book/detail' => "works#book_detail"
  get 'works/music' => "works#music"
  get 'works/ajax_music_list' => "works#ajax_music_list"
  get 'works/music/detail' => "works#music_detail"
  get 'works/link' => "works#link"
  get 'works/ajax_link_list' => "works#ajax_link_list"
  get 'works/link/detail' => "works#link_detail"
  post 'works/save' => "works#save"
  get "works/:id/detail" => "works#detail"
  get "works/:id/edit" => "works#edit"
  get "works/:id/copy" => "works#copy"
  post "works/:id/update" => "works#update"
  post "works/:id/destroy" => "works#destroy"

  post "works/:id/create_bookmark" => "works#create_bookmark"
  post "works/:id/destroy_bookmark" => "works#destroy_bookmark"

  post "likes/:post_id/create" => "likes#create"
  post "likes/:post_id/destroy" => "likes#destroy"

  resources :invitations, only: [:create, :destroy]
  get 'invitation/:id' => "invitations#invitation"
  get 'invite' => "invitations#invite"

  post ":id/create_profile" => "lists#create_profile"
  post ":id/destroy_profile" => "lists#destroy_profile"
  post ":id/create_favorite" => "lists#create_favorite"
  post ":id/destroy_favorite" => "lists#destroy_favorite"

  get 'works/test' => "works#test"


  get '*path', to: 'application#render_404'
end
