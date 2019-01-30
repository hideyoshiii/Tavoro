Rails.application.routes.draw do

  root :to => 'works#index'

  devise_for :users, controllers: { registrations: 'registrations' }

  get ":id" => "users#profile"
  get ":id/posts" => "users#posts"
  get ":id/bookmarks" => "users#bookmarks"
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
  get "post/:id/detail" => "works#detail"
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
  get 'works/bookmark' => "works#bookmark"
  post 'works/save' => "works#save"
  get "works/:id/edit" => "works#edit"
  get "works/:id/copy" => "works#copy"
  post "works/:id/update" => "works#update"
  post "works/:id/destroy" => "works#destroy"

  post "works/:id/create_bookmark" => "works#create_bookmark"
  post "works/:id/destroy_bookmark" => "works#destroy_bookmark"

  get "likes/post/:post_id" => "likes#post"
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
