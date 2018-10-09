class WorksController < ApplicationController
  before_action :sign_in_required, only: [:index]

  def home
  end
  def index
  end

  def search
  	@movies = Tmdb::Search.keyword('Iron man')
  	@am = RSpotify::Album.find('41vPD50kQ7JeamkxQW7Vuy')
	if params[:title] #書籍名で検索
	@items = RakutenWebService::Books::Book.search(title: params[:title])
	elsif params[:author] #著者名で検索
	@items = RakutenWebService::Books::Book.search(author: params[:author])
	end
  end
end
