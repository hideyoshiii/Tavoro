class DemosController < ApplicationController

	
  	def detail
	  	@post = Post.find(params[:id])

	  	@user  = User.find_by(username: "hideyoshi")
	  	@current_user = @user
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
	  		@detail04 = @item["overview"]
	  		@detail05 = "TheMovieDB"
	  	end
	  	if @post.category == "tv"
	  		@item = Tmdb::TV.detail(@post.work_id)
	  		@detail01 = @item["last_episode_to_air"]["air_date"].slice(0..3)
	  		@detail04 = @item["overview"]
	  		@detail05 = "TheMovieDB"
	  	end
	  	if @post.category == "book"
	  		@items = RakutenWebService::Books::Book.search(isbn: @post.work_id.to_i)
		  	if @items.present?
				@item = @items.first
			end
	  		@detail01 = @item["salesDate"].slice(0..3)
	  		@detail02 = @item["author"]
	  		@detail02 = "著者 : " + @detail02
	  		@detail04 = @item["itemCaption"]
	  		@detail05 = "楽天books"
	  	end
	  	if @post.category == "comic"
	  		@items = RakutenWebService::Books::Book.search(isbn: @post.work_id.to_i)
		  	if @items.present?
				@item = @items.first
			end
	  		@detail01 = @item["salesDate"].slice(0..3)
	  		@detail02 = @item["author"]
	  		@detail02 = "著者 : " + @detail02
	  		@detail04 = @item["itemCaption"]
	  		@detail05 = "楽天books"
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
	  		@detail04 = @item["primaryGenreName"]
	  		@detail05 = "iTunes"
	  	end
  	end

  	def posts
		@user  = User.find_by(username: "hideyoshi")
		@current_user = @user
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


end