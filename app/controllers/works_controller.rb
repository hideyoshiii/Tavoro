class WorksController < ApplicationController
  before_action :authenticate_user!, except: [:index, :post, :detail]

  def test
  end

  def index  
    if user_signed_in? 
      @user  = User.find(current_user.id)
      @users = @user.followings
      @posts = Post.all
      @posts = @posts.where(user_id: @user).or(@posts.where(user_id: @users))
      @posts = @posts.order(created_at: "DESC")
      @posts = @posts.page(params[:page]).per(10)
    end
  end

  def post
    @post = Post.find(params[:id])
    #画像定義
    if @post.image_url.present?
      if @post.category == "movie" || @post.category == "tv"
        @poster_show = @post.image_url.sub(/original/, 'w500')
      end
      if @post.category == "book" || @post.category == "comic"
        if @post.api == "itunes"
          @poster_show = @post.image_url.sub(/1000x1000bb/, '500x500bb')
        else
          @poster_show = @post.image_url.sub(/jpg/, 'jpg?_ex=500x500')
        end
      end
      if @post.category == "music"
        @poster_show = @post.image_url.sub(/1000x1000bb/, '500x500bb')
      end
    end
    #映画の時
    if @post.category == "movie"
      @item = Tmdb::Movie.detail(@post.work_id)
      if @item.present?
        @release = @item["release_date"].slice(0..3)
        @producer = Tmdb::Movie.director(@post.work_id)
        if @producer.present?
          @producer = @producer.first["name"]
        end
      end
    end
    #テレビの時
    if @post.category == "tv"
      @item = Tmdb::TV.detail(@post.work_id)
      if @item.present?
        @release = @item["first_air_date"].slice(0..3)
        if @item["created_by"].present?
          @producer = @item["created_by"][0]["name"]
        end
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
  	@defaults = ITunesSearchAPI.search(:term => "comic", :country => "jp", :media => "ebook", :limit  => '30')
  end

  def ajax_book_list
    if params[:q].present?
      @items_itunes = ITunesSearchAPI.search(:term => params[:q], :country => "jp", :media => "ebook", :limit  => '30')
      if @items_itunes.present?
        if @items_itunes.size <= 10
          @items_rakuten = RakutenWebService::Books::Book.search(title: params[:q], hits: 30)
        end
      else
        @items_rakuten = RakutenWebService::Books::Book.search(title: params[:q], hits: 30)
      end
    else
      @defaults = ITunesSearchAPI.search(:term => "comic", :country => "jp", :media => "ebook", :limit  => '30')
    end
  end

  def music
  	@defaults = ITunesSearchAPI.search(:term => "jpop", :country => "jp", :media => "music",:entity =>'song', :limit  => '30', :attribute => "mixTerm")
  end

  def ajax_music_list
    if params[:q].present?
      @items = ITunesSearchAPI.search(:term => params[:q], :country => "jp", :media => "music",:entity =>'song', :limit  => '30')
    else
      @defaults = ITunesSearchAPI.search(:term => "jpop", :country => "jp", :media => "music",:entity =>'song', :limit  => '30', :attribute => "mixTerm")
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
    #画像定義
    if @poster.present?
      if @category == "movie" || @category == "tv"
        @poster_show = @poster.sub(/original/, 'w500')
      end
      if @category == "book" || @category == "comic"
        if @api == "itunes"
          @poster_show = @poster.sub(/1000x1000bb/, '500x500bb')
        else
          @poster_show = @poster.sub(/jpg/, 'jpg?_ex=500x500')
        end
      end
      if @category == "music"
        @poster_show = @poster.sub(/1000x1000bb/, '500x500bb')
      end
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
    #画像定義
    if @post.image_url.present?
      if @post.category == "movie" || @post.category == "tv"
        @poster_show = @post.image_url.sub(/original/, 'w500')
      end
      if @post.category == "book" || @post.category == "comic"
        if @post.api == "itunes"
          @poster_show = @post.image_url.sub(/1000x1000bb/, '500x500bb')
        else
          @poster_show = @post.image_url.sub(/jpg/, 'jpg?_ex=500x500')
        end
      end
      if @post.category == "music"
        @poster_show = @post.image_url.sub(/1000x1000bb/, '500x500bb')
      end
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
    if params[:latest]
      if params[:latest] == "latest"
        @post.created_at = Time.now
      end
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