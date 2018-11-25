class WorksController < ApplicationController
  before_action :authenticate_user!, except: :index


  def test
  end

  def index
    if user_signed_in?
      @user  = User.find(current_user.id)
      @users = @user.followings
      @posts = []
      @posts_mine = Post.where(user_id: @user.id).order(created_at: "DESC")
      @posts_mine = @posts_mine.where.not(review: "bookmark")
      #もしカテゴリー指定がなければ
      if params[:category].blank?
        @category = "all"
        @posts.concat(@posts_mine)
        if @users.present?
          @users.each do |user|
              posts = Post.where(user_id: user.id)
              posts = posts.where.not(review: "bookmark")
              #取得したユーザーの投稿一覧を@postsに格納
              @posts.concat(posts)
          end  
        end
      else
        @category = params[:category]
        @posts_mine = @posts_mine.where(category: @category)
        @posts.concat(@posts_mine)
        if @users.present?
          @users.each do |user|
              posts = Post.where(user_id: user.id)
              posts = posts.where.not(review: "bookmark")
              posts = posts.where(category: @category)
              #取得したユーザーの投稿一覧を@postsに格納
              @posts.concat(posts)
          end  
        end
      end
      #@postsを新しい順に並べたい
      @posts.sort_by!{|post| post.created_at}.reverse!
      @posts = @posts.take(25)
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
      @poster = "https://image.tmdb.org/t/p/original/" + @item["poster_path"].to_s
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
      @poster = "https://image.tmdb.org/t/p/original/" + @item["poster_path"].to_s
	  	@poster_ja = Tmdb::TV.posters(@item["id"], language: 'ja')
	  	@poster_ja = @poster_ja.sort_by! { |a| -a[:vote_average] }.first(2)
	    @poster_en = Tmdb::TV.posters(@item["id"], language: 'en')
	    @poster_en = @poster_en.sort_by! { |a| -a[:vote_average] }.first(6)
	    @posters = @poster_ja + @poster_en
	end
  end

  def ajax_movie_list
  	if params[:q].present?
	  	@items = Tmdb::Search.multi(params[:q])
      @items = @items[:results]
  	end
  end

  def book
  	@defaults = RakutenWebService::Books::Book.search(size: 2,sort: "reviewCount", hits: 15)
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
  	if params[:q].present?
  		@items = RakutenWebService::Books::Book.search(title: params[:q], hits: 15)
  	end
  end

  def music
  	@defaults = ITunesSearchAPI.search(:term => "jpop", :country => "jp", :media => "music",:entity =>'song', :limit  => '20', :attribute => "mixTerm")
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
  	if params[:q].present?
  		@items = ITunesSearchAPI.search(:term => params[:q], :country => "jp", :media => "music",:entity =>'song', :limit  => '20')
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
      redirect_to root_path
    else
      #保存に失敗した場合
      redirect_to root_path
    end     
  end

  def detail
  	@post = Post.find(params[:id])

  	@users = current_user.followings
  	@comments = []
    @comments_mine = Post.where(user_id: current_user.id, work_id: @post.work_id).order('id DESC')
    @comments.concat(@comments_mine)

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

    if current_user == @post.user
      @comments_all = @comments
    else
      @comments_all = @comments.push(@post)
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
      #保存に成功した場合
      redirect_to root_path
    else
      #保存に失敗した場合
      redirect_to root_path
    end   
  end

  def destroy
  	@post = Post.find(params[:id])
    if @post.destroy
      #削除に成功した場合
      redirect_to root_path
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
      @post_bookmark = Post.create(user_id: current_user.id, title: @post.title, category: @post.category, image_url: @post.image_url, review: "bookmark", work_id: @post.work_id)
    end
  end

  def destroy_bookmark 
    @post = Post.find(params[:id].to_s) 
    @post_bookmark = Post.find_by(user_id: current_user.id, category: @post.category, review: "bookmark", work_id: @post.work_id)
    @post_bookmark.destroy 
  end

  def create_list
    @post = Post.find(params[:id].to_s) 
    @lists = List.where(user_id: current_user.id, title: "プロフィール")
    if @lists.present?
      @lists.destroy_all
    end
    @post_list = List.create(user_id: current_user.id, post_id: @post.id, title: "プロフィール")
  end

  def destroy_list 
    @post = Post.find(params[:id].to_s) 
    @post_list = List.find_by(user_id: current_user.id, post_id: @post.id, title: "プロフィール")
    @post_list.destroy 
  end

end
