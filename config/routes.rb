Rails.application.routes.draw do

  root :to => 'works#home'

  devise_for :users

  get 'works/index'
  get 'works/search'
end
