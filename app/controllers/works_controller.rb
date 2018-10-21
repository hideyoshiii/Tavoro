class WorksController < ApplicationController
  before_action :sign_in_required, only: [:index]

  def home
  end

  def test
  end

  def index

  	@user  = User.find(current_user.id)

  	@users = @user.followings
  	@posts = []
  	@posts_mine = Post.where(user_id: current_user.id).order('id DESC')
  	@posts.concat(@posts_mine)

  	if @users.present?
        @users.each do |user|
          	posts = Post.where(user_id: user.id).order(created_at: :desc)
          	#取得したユーザーの投稿一覧を@postsに格納
          	@posts.concat(posts)
        end
        #@postsを新しい順に並べたい
        @posts.sort_by!{|post| post.created_at}.reverse!
    end

  end

  def category
    @user  = User.find(current_user.id)
    @users = @user.followings

    if params[:q].present?
      @posts = []
      @posts_mine = Post.where(user_id: current_user.id, category: params[:q]).order('id DESC')
      @posts.concat(@posts_mine)
      
      if @users.present?
          @users.each do |user|
              posts = Post.where(user_id: user.id, category: params[:q]).order(created_at: :desc)
              #取得したユーザーの投稿一覧を@postsに格納
              @posts.concat(posts)
          end
          #@postsを新しい順に並べたい
          @posts.sort_by!{|post| post.created_at}.reverse!
      end
    end
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
  	@defaults = Tmdb::Movie.popular
  	@defaults = @defaults[:results]
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
  	if params[:q].nil?
	  	@defaults = Tmdb::Movie.latest
	  	@defaults = @defaults[:results]
  	else
	    @items = Tmdb::Search.multi(params[:q])
		@items = @items[:results]
	end
  end

  def book
  	@defaults = RakutenWebService::Books::Book.search(size: 2,sort: "reviewCount")
  end

  def book_detail
  	@items = RakutenWebService::Books::Book.search(isbn: params[:id].to_i)
  	if @items.present?
		@item = @items.first
	end
  	@title = @item["title"]
  	@work_id = @item["isbn"]
  	@category = params[:type]
  	@poster = @item["largeImageUrl"]
    @poster = @poster.sub!(/_ex.*/m, "")
    @poster = @poster.chop!
  end

  def ajax_book_list
  	if params[:q].nil?
  		@defaults = RakutenWebService::Books::Book.search(size: 2,sort: "reviewCount")
  	else
  		@items = RakutenWebService::Books::Book.search(title: params[:q])
  	end
  end

  def music
  	@defaults = ITunesSearchAPI.search(:term => "jpop", :country => "jp", :media => "music", :limit  => '20', :attribute => "mixTerm")
  end

  def music_detail
  	@items = ITunesSearchAPI.lookup(:id => params[:id].to_i, :country => "jp")
  	if @items.present?
		@item = @items.first
	end
	@title = @item["trackCensoredName"]
  	@work_id = @item["trackId"]
  	@category = params[:type]
  	@poster = @item["artworkUrl100"]
  	@poster = @poster.sub(/100x100bb/, '1000x1000bb')
  	@preview_url = @item["previewUrl"]
  end

  def ajax_music_list
  	if params[:q].nil?
  		@defaults = ITunesSearchAPI.search(:term => "jpop", :country => "jp", :media => "music", :limit  => '20', :attribute => "mixTerm")
  	else
  		@items = ITunesSearchAPI.search(:term => params[:q], :country => "jp", :media => "music", :limit  => '20')
  	end
  end

  def save
  	if params[:category] == "movie" || params[:category] == "tv"
  		@post = Post.new(user_id: current_user.id, title: params[:title], description: params[:description], category: params[:category], image_url: params[:image_url], review: params[:review], work_id: params[:work_id])
  	end
  	if params[:category] == "book" || params[:category] == "comic"
  		@post = Post.new(user_id: current_user.id, title: params[:title], description: params[:description], category: params[:category], image_url: params[:image_url], review: params[:review], work_id: params[:work_id])
  	end
  	if params[:category] == "music"
  		@post = Post.new(user_id: current_user.id, title: params[:title], description: params[:description], category: params[:category], image_url: params[:image_url], review: params[:review], work_id: params[:work_id], preview_url: params[:preview_url])
  	end
  	if @post.save
      #保存に成功した場合
      redirect_to "/works/index", notice: "保存しました" 
    else
      #保存に失敗した場合
      redirect_to "/works/index", notice: "保存に失敗しました" 
    end     
  end

  def detail
  	@post = Post.find(params[:id])

  	@users = current_user.followings
  	@comments = []

  	if @users.present?
        @users.each do |user|
        	unless user == @post.user
          		comments = Post.where(user_id: user.id, work_id: @post.work_id).order(created_at: :desc)
          		#取得したユーザーの投稿一覧を@postsに格納
	          	@comments.concat(comments)
	        end
        end
        #@postsを新しい順に並べたい
        @comments.sort_by!{|post| post.created_at}.reverse!
    end

  	if @post.category == "movie"
  		@item = Tmdb::Movie.detail(@post.work_id)
  		@detail01 = @item["release_date"].slice(0..3)
  		@detail02 = @item["runtime"]
  		@detail02 = "上映時間 : " + @detail02.to_s + "分"
  		@detail03 = Tmdb::Movie.director(@post.work_id).first["name"]
  		@detail03 = "監督 : " + @detail03
  	end
  	if @post.category == "tv"
  		@item = Tmdb::TV.detail(@post.work_id)
  		@detail01 = @item["last_episode_to_air"]["air_date"].slice(0..3)
  	end
  	if @post.category == "book"
  		@items = RakutenWebService::Books::Book.search(isbn: @post.work_id.to_i)
	  	if @items.present?
			@item = @items.first
		end
  		@detail01 = @item["salesDate"].slice(0..3)
  		@detail02 = @item["author"]
  		@detail02 = "著者 : " + @detail02
  	end
  	if @post.category == "comic"
  		@items = RakutenWebService::Books::Book.search(isbn: @post.work_id.to_i)
	  	if @items.present?
			@item = @items.first
		end
  		@detail01 = @item["salesDate"].slice(0..3)
  		@detail02 = @item["author"]
  		@detail02 = "著者 : " + @detail02
  	end
  	if @post.category == "music"
  		@items = ITunesSearchAPI.lookup(:id => @post.work_id.to_i, :country => "jp")
	  	if @items.present?
			@item = @items.first
		end
  		@detail01 = @item["releaseDate"].slice(0..3)
  		@detail02 = @item["artistName"]
  		@detail02 = "アーティスト : " + @detail02
  		@detail03 = @item["collectionName"]
  		@detail03 = "アルバム : " + @detail03
  	end
  end


  def edit
  	@post = Post.find(params[:id])

  	@favorite = false
  	@good = false
  	@bad = false
  	if @post.review == "favorite"
  		@favorite = true
  	end
  	if @post.review == "good"
  		@good = true
  	end
  	if @post.review == "bad"
  		@bad = true
  	end
    if !(current_user == @post.user)
      redirect_to root_path
    end

    if @post.category == "movie"
  		@item = Tmdb::Movie.detail(@post.work_id)
	  	@poster_ja = Tmdb::Movie.posters(@post.work_id, language: 'ja')
	  	@poster_ja = @poster_ja.sort_by! { |a| -a[:vote_average] }.first(2)
	    @poster_en = Tmdb::Movie.posters(@post.work_id, language: 'en')
	    @poster_en = @poster_en.sort_by! { |a| -a[:vote_average] }.first(6)
	    @posters = @poster_ja + @poster_en
	end
	if @post.category == "tv"
  		@item = Tmdb::TV.detail(@post.work_id)
	  	@poster_ja = Tmdb::TV.posters(@post.work_id, language: 'ja')
	  	@poster_ja = @poster_ja.sort_by! { |a| -a[:vote_average] }.first(2)
	    @poster_en = Tmdb::TV.posters(@post.work_id, language: 'en')
	    @poster_en = @poster_en.sort_by! { |a| -a[:vote_average] }.first(6)
	    @posters = @poster_ja + @poster_en
	end

  end

  def copy
  		@post = Post.find(params[:id])

	  	if @post.category == "movie"
	  		@item = Tmdb::Movie.detail(@post.work_id)
		  	@poster_ja = Tmdb::Movie.posters(@post.work_id, language: 'ja')
		  	@poster_ja = @poster_ja.sort_by! { |a| -a[:vote_average] }.first(2)
		    @poster_en = Tmdb::Movie.posters(@post.work_id, language: 'en')
		    @poster_en = @poster_en.sort_by! { |a| -a[:vote_average] }.first(6)
		    @posters = @poster_ja + @poster_en
		end
		if @post.category == "tv"
	  		@item = Tmdb::TV.detail(@post.work_id)
		  	@poster_ja = Tmdb::TV.posters(@post.work_id, language: 'ja')
		  	@poster_ja = @poster_ja.sort_by! { |a| -a[:vote_average] }.first(2)
		    @poster_en = Tmdb::TV.posters(@post.work_id, language: 'en')
		    @poster_en = @poster_en.sort_by! { |a| -a[:vote_average] }.first(6)
		    @posters = @poster_ja + @poster_en
		end
  end

  def update
  	@post = Post.find(params[:id])
  	if params[:description]
  		@post.description = params[:description]
  	end
  	if params[:review]
  		@post.review = params[:review]
  	end
  	if params[:image_url]
  		@post.image_url = params[:image_url]
  	end
    if @post.save
      redirect_to "/works/index"
    end
  end

  def destroy
  	@post = Post.find(params[:id])
    if @post.destroy
    	redirect_to "/works/index"
	end
  end

end
