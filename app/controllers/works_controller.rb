class WorksController < ApplicationController
  before_action :authenticate_user!, except: [:index, :post, :detail]

  def test
    @user = current_user
    if @user
      @alls = Post.where(user_id: @user.id).order(created_at: "DESC")
      @checkeds_i = @alls.where.not(review: "bookmark").size
      @bookmarks_i = @alls.where(review: "bookmark").size

      @all = @alls.where.not(review: "bookmark")
      @movie = @all.where(category: "movie")
      @tv = @all.where(category: "tv")
      @book = @all.where(category: "book")
      @comic = @all.where(category: "comic")
      @music = @all.where(category: "music")

      @list_favorite = List.find_by(user_id: @user.id, title: "お気に入り")
      if @list_favorite.present?
        @list_favorite_items = ListItem.where(list_id: @list_favorite.id).order(created_at: "DESC")
      end
    end
  end

  def index  
    if user_signed_in? 
      @user  = User.find(current_user.id)
      @users = @user.followings
      @posts = Post.where.not(review: "bookmark")
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
    @post = Post.find(params[:id].to_i)
  end

  def detail
    @post = Post.find(params[:id])
    if user_signed_in?
      if current_user == @post.user
        @relation = true
      else
        if current_user.following?(@post.user)
          @relation = true
        else
          @relation = false
        end
      end
    else
      @relation = false
    end
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
        @posts_unfollow = @posts_all.where.not(user_id: @users).where.not(user_id: current_user)
      end
    #ログインしてない時
    else
      if @posts_all.present? 
        @posts_unfollow = @posts_all
      end
    end
    #映画の時
    if @post.category == "movie"
      @item = Tmdb::Movie.detail(@post.work_id)
      if @item.present?
        @detail01 = @item["release_date"].slice(0..3)
        @detail02 = @item["runtime"]
        if @detail02.present?
          @detail02 = "上映時間 : " + @detail02.to_s + "分"
        end
        @detail03 = Tmdb::Movie.director(@post.work_id).first["name"]
        if @detail03.present?
          @detail03 = "監督 : " + @detail03
        end
      end
    end
    #テレビの時
    if @post.category == "tv"
      @item = Tmdb::TV.detail(@post.work_id)
      if @item.present?
        @detail01 = @item["first_air_date"].slice(0..3)
        if @item["genres"].present?
          @detail02 = @item["genres"][0]["name"]
          if @detail02.present?
            @detail02 = "ジャンル : " + @detail02
          end
        end
        if @item["created_by"].present?
          @detail03 = @item["created_by"][0]["name"]
          if @detail03.present?
            @detail03 = "制作 : " + @detail03
          end
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
            @detail01 = @item["releaseDate"].slice(0..3)
            @detail02 = @item["artistName"]
            if @detail02.present?
              @detail02 = "著者 : " + @detail02
            end
          end
        end
      else
        @items = RakutenWebService::Books::Book.search(isbn: @post.work_id.to_i)
        if @items.present?
          @item = @items.first
          if @item.present?
            @detail01 = @item["salesDate"].slice(0..3)
            @detail02 = @item["author"]
            if @detail02.present?
              @detail02 = "著者 : " + @detail02
            end
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
            @detail01 = @item["releaseDate"].slice(0..3)
            @detail02 = @item["artistName"]
            if @detail02.present?
              @detail02 = "著者 : " + @detail02
            end
          end
        end
      else
        @items = RakutenWebService::Books::Book.search(isbn: @post.work_id.to_i)
        if @items.present?
          @item = @items.first
          if @item.present?
            @detail01 = @item["salesDate"].slice(0..3)
            @detail02 = @item["author"]
            if @detail02.present?
              @detail02 = "著者 : " + @detail02
            end
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
          @detail01 = @item["releaseDate"].slice(0..3)
          @detail02 = @item["artistName"]
          if @detail02.present?
            @detail02 = "アーティスト : " + @detail02
          end
          @detail03 = @item["collectionName"]
          if @detail03.present?
            @detail03 = "アルバム : " + @detail03
          end
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

  def movie_detail
  	if params[:type] == "movie"
  		@item = Tmdb::Movie.detail(params[:id].to_i)
  		@title = @item["title"]
  		@work_id = @item["id"]
  		@category = params[:type]
      @poster = "https://image.tmdb.org/t/p/original" + @item["poster_path"].to_s
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
        @poster = "https://image.tmdb.org/t/p/original" + @item["poster_path"].to_s
  	  	@poster_ja = Tmdb::TV.posters(@item["id"], language: 'ja')
  	  	@poster_ja = @poster_ja.sort_by! { |a| -a[:vote_average] }.first(2)
  	    @poster_en = Tmdb::TV.posters(@item["id"], language: 'en')
  	    @poster_en = @poster_en.sort_by! { |a| -a[:vote_average] }.first(6)
  	    @posters = @poster_ja + @poster_en
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

  def book_detail
    if params[:api] == "rakuten"
      @api = "rakuten"
    	@items = RakutenWebService::Books::Book.search(isbn: params[:id].to_i)
    	if @items.present?
  		  @item = @items.first
  	  end
    	@title = @item["title"]
    	@work_id = params[:id].to_i
    	@category = params[:type]
    	@poster = @item["largeImageUrl"]
      @poster = @poster.sub!(/_ex.*/m, "")
      @poster = @poster.chop!
    end
    if params[:api] == "itunes"
      @api = "itunes"
      @items = ITunesSearchAPI.lookup(:id => params[:id].to_i, :country => "jp")
      if @items.present?
        @item = @items.first
      end
      @title = @item["trackCensoredName"]
      @work_id = params[:id].to_i
      @category = params[:type]
      @poster = @item["artworkUrl100"]
      @poster = @poster.sub(/100x100bb/, '1000x1000bb')
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

  def link
  end

  def ajax_link_list
    if params[:q].present?
      #URLを定義
      @url = params[:q]
      #正規表現バリデーション
      if @url.match(/\A#{URI::regexp(%w(https))}\z/)
        #サーバーバリデーション
        begin
          @response = Net::HTTP.get_response(URI.parse(@url))
        rescue
          @error = "指定されたURL先でエラーが発生しました"
        else
          #404バリデーション
          begin
            @file = open(@url)
            @doc = Nokogiri::HTML(@file)
          rescue OpenURI::HTTPError => e     
            @error = "指定されたURL先ででエラーが発生しました"
          else
            @success = "URLが正常に検知されました"
          end
        end  
      else
        @error = "httpsから始まるURLを入力してください"
      end
    end
  end

  def link_detail
    url = params[:url]
    uri = url
    page = URI.parse(uri).read
    charset = page.charset
    if charset == "iso-8859-1"
      charset = page.scan(/charset="?([^\s"]*)/i).first.join
    end
    @doc = Nokogiri::HTML(page, uri, charset)
    #諸情報
    if @doc.present?
      #title
      if @doc.css('//meta[property="og:title"]/@content').empty?
        @title = @doc.title.to_s
      else
        @title = @doc.css('//meta[property="og:title"]/@content').to_s
      end
      #url
      @preview_url = url
      #category
      @category = "link"
      #imgae
      @posters = []
      unless @doc.css('//meta[property="og:site_name"]/@content').empty?
        @posters << @doc.css('//meta[property="og:image"]/@content').to_s
      end
      unless @doc.css('img').empty?
        @doc.css('img').each do |photo|
          @posters << photo[:src]
        end 
      end
      if @posters.present?
        @posters.each do |poster|
          unless poster.match(/\A#{URI::regexp(%w(https))}\z/)
            @posters.delete(poster)
          end
        end
        if @posters.present?
          @poster = @posters.first
          @posters = @posters.take(6)
        end
      end
    end
  end

  def bookmark
    @user = User.find_by(id: current_user.id) 
    if @user
      @alls = Post.where(user_id: @user.id).order(created_at: "DESC")

      @all = @alls.where(review: "bookmark")
      @movie = @all.where(category: "movie")
      @tv = @all.where(category: "tv")
      @book = @all.where(category: "book")
      @comic = @all.where(category: "comic")
      @music = @all.where(category: "music")
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
      redirect_to "/post/#{@post.id}"
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

    @bookmark = false
    @good = false
  	@favorite = false
  	@bad = false
    if @post.review == "bookmark"
      @bookmark = true
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
  	if params[:image_url]
  		@post.image_url = params[:image_url]
  	end
    if params[:review]
      if @post.review == "bookmark"
        unless params[:review] == "bookmark"
          @post.created_at = Time.now
        end
        @post.review = params[:review]
      else
        if params[:review] == "bookmark"
          @post.created_at = Time.now
        end
        @post.review = params[:review]
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
      if @review == "bookmark"
        redirect_to "/#{current_user.username}/bookmarks"
      else
        redirect_to "/#{current_user.username}/posts"
      end
    else
      #削除に失敗した場合
      redirect_to root_path
    end   
  end

  def create_bookmark   
    @post = Post.find(params[:id].to_s) 
    if @post.category == "music"
      @post_bookmark = Post.create(user_id: current_user.id, title: @post.title, category: @post.category, image_url: @post.image_url, review: "bookmark", work_id: @post.work_id, preview_url: @post.preview_url)
    else
      if @post.category == "book" || @post.category == "comic"
        @post_bookmark = Post.create(user_id: current_user.id, title: @post.title, category: @post.category, image_url: @post.image_url, review: "bookmark", work_id: @post.work_id, api: @post.api)
      else
        @post_bookmark = Post.create(user_id: current_user.id, title: @post.title, category: @post.category, image_url: @post.image_url, review: "bookmark", work_id: @post.work_id)
      end
    end
  end

  def destroy_bookmark 
    @post = Post.find(params[:id].to_s) 
    @post_bookmark = Post.find_by(user_id: current_user.id, category: @post.category, review: "bookmark", work_id: @post.work_id, preview_url: @post.preview_url)
    @post_bookmark.destroy
  end

end
