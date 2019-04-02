class WorksController < ApplicationController
  before_action :authenticate_user!, except: [:index, :post, :detail]

  def test
  end

  def index  
    if user_signed_in? 
      @user  = User.find(current_user.id)
      @users = @user.followings
      @posts = Post.all
      #categoryのfillter
      if params[:category].present?
        @fillter_category = params[:category]
        unless @fillter_category == "all"
          @posts = @posts.where(category: @fillter_category)
        end
      end
      @posts = @posts.where(user_id: @user).or(@posts.where(user_id: @users))
      @posts = @posts.order(created_at: "DESC").limit(20)
      #labelの真偽
      @all = false
      @movie = false
      @tv = false
      @book = false
      @comic = false
      @music = false
      if params[:category].present?
        if params[:category] == "all"
          @all = true
        end
        if params[:category] == "movie"
          @movie = true
        end
        if params[:category] == "tv"
          @tv = true
        end
        if params[:category] == "book"
          @book = true
        end
        if params[:category] == "comic"
          @comic = true
        end
        if params[:category] == "music"
          @music = true
        end
      else
        @all = true
      end
    else
      @posts_all = Post.where.not(review: "bookmark")
      @posts = @posts_all.order(created_at: "DESC").limit(20)
      @users = User.find(@posts_all.group(:user_id).order('count(user_id) desc').limit(10).pluck(:user_id))
    end
  end

  def post
    @post = Post.find(params[:id])
    @posts_all = Post.where(category: @post.category, work_id: @post.work_id).order('id DESC')
    if @posts_all.present? 
      @posts_all = @posts_all.where.not(id: @post.id)  
    end
    #ログインしている時
    if user_signed_in?
      @users = current_user.followings
      if @posts_all.present? 
        @posts_mine = @posts_all.where(user_id: current_user.id)   
        @posts_follow = @posts_all.where(user_id: @users)
        @posts_other = @posts_mine + @posts_follow
      end
    end
    #映画の時
    if @post.category == "movie"
      @item = Tmdb::Movie.detail(@post.work_id)
      if @item.present?
        @release = @item["release_date"].slice(0..3)
        @producer = Tmdb::Movie.director(@post.work_id).first["name"]
      end
    end
    #テレビの時
    if @post.category == "tv"
      @item = Tmdb::TV.detail(@post.work_id)
      if @item.present?
        @release = @item["first_air_date"].slice(0..3)
        @producer = @item["created_by"][0]["name"]
      end
    end
    #ブックの時
    if @post.category == "book"
      if @post.api == "itunes"
        @items = ITunesSearchAPI.lookup(:id => @post.work_id.to_i, :country => "jp")
        if @items.present?
          @item = @items.first
          if @item.present?
            @release = @item["releaseDate"].slice(0..3)
            @producer = @item["artistName"]
          end
        end
      else
        @items = RakutenWebService::Books::Book.search(isbn: @post.work_id.to_i)
        if @items.present?
          @item = @items.first
          if @item.present?
            @release = @item["salesDate"].slice(0..3)
            @producer = @item["author"]
          end
        end
      end
    end
    #コミックの時
    if @post.category == "comic"
      if @post.api == "itunes"
        @items = ITunesSearchAPI.lookup(:id => @post.work_id.to_i, :country => "jp")
        if @items.present?
          @item = @items.first
          if @item.present?
            @release = @item["releaseDate"].slice(0..3)
            @producer = @item["artistName"]
          end
        end
      else
        @items = RakutenWebService::Books::Book.search(isbn: @post.work_id.to_i)
        if @items.present?
          @item = @items.first
          if @item.present?
            @release = @item["salesDate"].slice(0..3)
            @producer = @item["author"]
          end
        end
      end
    end
    #ミュージックの時
    if @post.category == "music"
      @items = ITunesSearchAPI.lookup(:id => @post.work_id.to_i, :country => "jp")
      if @items.present?
        @item = @items.first
        if @item.present?
          @release = @item["releaseDate"].slice(0..3)
          @producer = @item["artistName"]
        end
      end
    end
  end

  def movie
  	@defaults = Tmdb::Movie.popular
  	@defaults = @defaults[:results]
  end

  def ajax_movie_list
    if params[:q].present?
      @items = Tmdb::Search.multi(params[:q])
      @items = @items[:results]
    else
      @defaults = Tmdb::Movie.popular
      @defaults = @defaults[:results]
    end
  end

  def book
  	@defaults = ITunesSearchAPI.search(:term => "comic", :country => "jp", :media => "ebook", :limit  => '20')
  end

  def ajax_book_list
    if params[:q].present?
      @items_itunes = ITunesSearchAPI.search(:term => params[:q], :country => "jp", :media => "ebook", :limit  => '20')
      if @items_itunes.present?
        if @items_itunes.size <= 10
          @items_rakuten = RakutenWebService::Books::Book.search(title: params[:q], hits: 20)
        end
      else
        @items_rakuten = RakutenWebService::Books::Book.search(title: params[:q], hits: 20)
      end
    else
      @defaults = ITunesSearchAPI.search(:term => "comic", :country => "jp", :media => "ebook", :limit  => '20')
    end
  end

  def music
  	@defaults = ITunesSearchAPI.search(:term => "jpop", :country => "jp", :media => "music",:entity =>'song', :limit  => '20', :attribute => "mixTerm")
  end

  def ajax_music_list
    if params[:q].present?
      @items = ITunesSearchAPI.search(:term => params[:q], :country => "jp", :media => "music",:entity =>'song', :limit  => '30')
    else
      @defaults = ITunesSearchAPI.search(:term => "jpop", :country => "jp", :media => "music",:entity =>'song', :limit  => '20', :attribute => "mixTerm")
    end
  end

  def new
    if params[:category] == "movie" || params[:category] == "tv"
      if params[:category] == "movie"
        @item = Tmdb::Movie.detail(params[:id].to_i)
        @title = @item["title"]
        @work_id = @item["id"]
        @category = params[:category]
        @poster = "https://image.tmdb.org/t/p/original" + @item["poster_path"].to_s
        @poster_ja = Tmdb::Movie.posters(@item["id"], language: 'ja')
        @poster_ja = @poster_ja.sort_by! { |a| -a[:vote_average] }.first(2)
        @poster_en = Tmdb::Movie.posters(@item["id"], language: 'en')
        @poster_en = @poster_en.sort_by! { |a| -a[:vote_average] }.first(6)
        @posters = @poster_ja + @poster_en
     end
      if params[:category] == "tv"
        @item = Tmdb::TV.detail(params[:id].to_i)
        @title = @item["name"]
        @work_id = @item["id"]
        @category = params[:category]
        @poster = "https://image.tmdb.org/t/p/original" + @item["poster_path"].to_s
        @poster_ja = Tmdb::TV.posters(@item["id"], language: 'ja')
        @poster_ja = @poster_ja.sort_by! { |a| -a[:vote_average] }.first(2)
        @poster_en = Tmdb::TV.posters(@item["id"], language: 'en')
        @poster_en = @poster_en.sort_by! { |a| -a[:vote_average] }.first(6)
        @posters = @poster_ja + @poster_en
      end
    end
    if params[:category] == "book" || params[:category] == "comic"
      if params[:api] == "rakuten"
        @items = RakutenWebService::Books::Book.search(isbn: params[:id].to_i)
        if @items.present?
          @item = @items.first
        end
        @title = @item["title"]
        @work_id = params[:id].to_i
        @category = params[:category]
        @poster = @item["largeImageUrl"]
        @poster = @poster.sub!(/_ex.*/m, "")
        @poster = @poster.chop!
        @api = "rakuten"
      end
      if params[:api] == "itunes"
        @items = ITunesSearchAPI.lookup(:id => params[:id].to_i, :country => "jp")
        if @items.present?
          @item = @items.first
        end
        @title = @item["trackCensoredName"]
        @work_id = params[:id].to_i
        @category = params[:category]
        @poster = @item["artworkUrl100"]
        @poster = @poster.sub(/100x100bb/, '1000x1000bb')
        @api = "itunes"
      end
    end
    if params[:category] == "music"
      @items = ITunesSearchAPI.lookup(:id => params[:id].to_i, :country => "jp")
      if @items.present?
        @item = @items.first
      end
      @title = @item["trackCensoredName"]
      @work_id = @item["trackId"]
      @category = params[:category]
      @poster = @item["artworkUrl100"]
      @poster = @poster.sub(/100x100bb/, '1000x1000bb')
      @preview_url = @item["previewUrl"]
    end
  end

  def save
  	if params[:category] == "movie" || params[:category] == "tv"
  		@post = Post.new(user_id: current_user.id, title: params[:title], description: params[:description], category: params[:category], image_url: params[:image_url], review: params[:review], work_id: params[:work_id])
  	end
  	if params[:category] == "book" || params[:category] == "comic"
  		@post = Post.new(user_id: current_user.id, title: params[:title], description: params[:description], category: params[:category], image_url: params[:image_url], review: params[:review], work_id: params[:work_id], api: params[:api])
  	end
  	if params[:category] == "music"
  		@post = Post.new(user_id: current_user.id, title: params[:title], description: params[:description], category: params[:category], image_url: params[:image_url], review: params[:review], work_id: params[:work_id], preview_url: params[:preview_url])
  	end
    #保存に成功した場合
  	if @post.save
      redirect_to root_path
    #保存に失敗した場合
    else
      redirect_to root_path
    end     
  end

  def edit
  	@post = Post.find(params[:id])
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
    @bookmark = false
    @doing = false
    @good = false
    @favorite = false
    @bad = false
    if @post.review == "bookmark"
      @bookmark = true
    end
    if @post.review == "doing"
      @doing = true
    end
    if @post.review == "good"
      @good = true
    end
    if @post.review == "favorite"
      @favorite = true
    end
    if @post.review == "bad"
      @bad = true
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
  	if params[:image_url]
  		@post.image_url = params[:image_url]
  	end
    if params[:review]
      @post.review = params[:review]
    end
    if @post.save
      redirect_to "/post/#{@post.id}"
    else
      redirect_to root_path
    end   
  end

  def destroy
  	@post = Post.find(params[:id])
    @review = @post.review
    if @post.destroy
      #削除に成功した場合
      redirect_to "/#{current_user.username}"
    else
      #削除に失敗した場合
      redirect_to root_path
    end   
  end

end