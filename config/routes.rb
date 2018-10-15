Rails.application.routes.draw do

  root :to => 'works#home'

  devise_for :users, controllers: { registrations: 'registrations' }
  get "users/:id/collection" => "users#collection"

  get 'works/index' => "works#index"
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
  get 'works/save' => "works#save"
end
