class DemosController < ApplicationController

	def index
      @user  = User.find_by(username: "hideyoshi")
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

  	def detail
	  	@post = Post.find(99)

	  	@user  = User.find_by(username: "hideyoshi")
	  	@users = @user.followings
	  	@comments = []
	    @comments_mine = Post.where(user_id: @user.id, work_id: @post.work_id).order('id DESC')
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

	    if @user == @post.user
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

  	def posts
		@user  = User.find_by(username: "hideyoshi")
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

	def bookmarks
	    @user  = User.find_by(username: "hideyoshi")
	    if @user
	      @alls = Post.where(user_id: @user.id).order(created_at: "DESC")
	      @checkeds_i = @alls.where.not(review: "bookmark").size
	      @bookmarks_i = @alls.where(review: "bookmark").size

	      @all = @alls.where(review: "bookmark")
	      @movie = @all.where(category: "movie")
	      @tv = @all.where(category: "tv")
	      @book = @all.where(category: "book")
	      @comic = @all.where(category: "comic")
	      @music = @all.where(category: "music")
	    end
	  end


end