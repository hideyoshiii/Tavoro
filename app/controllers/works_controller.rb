class WorksController < ApplicationController
  before_action :sign_in_required, only: [:index]

  def home
  end

  def index
  	@posts = Post.where(user_id: current_user.id).order('id DESC')
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

  def movie_detail
  	if params[:type] == "movie"
  		@item = Tmdb::Movie.detail(params[:id].to_i)
  		@title = @item["title"]
  		@work_id = @item["id"]
  		@category = params[:type]
	  	@poster_ja = Tmdb::Movie.posters(@item["id"], language: 'ja')
	  	@poster_ja = @poster_ja.sort_by! { |a| -a[:vote_average] }.first(2)
	    @poster_en = Tmdb::Movie.posters(@item["id"], language: 'en')
	    @poster_en = @poster_en.sort_by! { |a| -a[:vote_average] }.first(6)
	    @posters = @poster_ja + @poster_en
	end
	if params[:type] == "tv"
  		@item = Tmdb::TV.detail(params[:id].to_i)
  		@title = @item["name"]
  		@work_id = @item["id"]
  		@category = params[:type]
	  	@poster_ja = Tmdb::TV.posters(@item["id"], language: 'ja')
	  	@poster_ja = @poster_ja.sort_by! { |a| -a[:vote_average] }.first(2)
	    @poster_en = Tmdb::TV.posters(@item["id"], language: 'en')
	    @poster_en = @poster_en.sort_by! { |a| -a[:vote_average] }.first(6)
	    @posters = @poster_ja + @poster_en
	end
  end

  def ajax_movie_list
    @items = Tmdb::Search.multi(params[:q])
	@items = @items[:results]
  end

  def book
  end

  def book_detail
  end

  def ajax_book_list
  	@items = RakutenWebService::Books::Book.search(title: params[:q])
  end

  def music
  end

  def music_detail
  end

  def ajax_music_list
  	@items = ITunesSearchAPI.search(:term => params[:q], :country => "jp", :media => "music", :limit  => '5')
  end

  def save
  	if params[:category] == "movie" || params[:category] == "tv"
  		@post = Post.new(user_id: current_user.id, title: params[:title], description: params[:description], category: params[:category], image_url: params[:image_url], review: params[:review], work_id: params[:work_id])
  	end
  	if @post.save
      #保存に成功した場合
      redirect_to "/works/index", notice: "保存しました" 
    else
      #保存に失敗した場合
      redirect_to "/works/index", notice: "保存に失敗しました" 
    end     
  end

end
