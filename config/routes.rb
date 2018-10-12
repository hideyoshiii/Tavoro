Rails.application.routes.draw do

  root :to => 'works#home'

  devise_for :users

  get 'works/index'
  get 'works/search'
  get 'works/movie'
  get 'works/ajax_movie_list'
  get 'works/book'
  get 'works/ajax_book_list'
  get 'works/music'
  get 'works/ajax_music_list'
end
