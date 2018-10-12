class WorksController < ApplicationController
  before_action :sign_in_required, only: [:index]

  def home
  end
  def index
  end

  def search
  	if params[:title_itunes]
  		@itunes = ITunesSearchAPI.search(:term => params[:title_itunes], :country => "jp", :media => "music", :limit  => '5')
  	end

  	if params[:title_movie]
	  	@tmdbs = Tmdb::Search.movie(params[:title_movie])
	  	@tmdbs = @tmdbs[:results]
	end

  	if params[:title_music]
	  	artists = RSpotify::Artist.search(params[:title_music])
		arctic_monkeys = artists.first
		albums = arctic_monkeys.albums
		am = albums.first
		@name = am.name
		@images = am.images
		@images = @images[0]
		@image = @images["url"]
		tracks = am.tracks
		@do_i_wanna_know = tracks.first
		playlists = RSpotify::Playlist.search('Indie')
		albums = RSpotify::Album.search('The Wall')
		tracks = RSpotify::Track.search('Thriller')
	end

	if params[:title] 
		@items = RakutenWebService::Books::Book.search(title: params[:title])
	end

  end

  def movie
  end

  def ajax_movie_list
    @items = Tmdb::Search.movie(params[:q])
	@items = @items[:results]
  end

  def book
  end

  def ajax_book_list
  	@items = RakutenWebService::Books::Book.search(title: params[:q])
  end

  def music
  end

  def ajax_music_list
  	@items = ITunesSearchAPI.search(:term => params[:q], :country => "jp", :media => "music", :limit  => '5')
  end
  
end
