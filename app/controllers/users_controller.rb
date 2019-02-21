class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:notifications]
  after_action :notifications_update, only: [:notifications]

  def profile
    @user = User.find_by(username: params[:id]) 
    @alls = Post.where(user_id: @user.id).order(created_at: "DESC")
    @checkeds_i = @alls.where.not(review: "bookmark").size
    @bookmarks_i = @alls.where(review: "bookmark").size

    @list = List.find_by(user_id: @user.id, title: "プロフィール")
    if @list.present?
      @list_item = ListItem.find_by(list_id: @list.id)
      if @list_item.present?
        @post_list = @list_item.post
      end
    end
  end

	def posts
		@user = User.find_by(username: params[:id])	
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
    @user = User.find_by(username: params[:id]) 
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

  def follow_request
    @user = current_user
    @users_requester = current_user.requesters
    @users_requesting = current_user.requestings
  end


	  def user
      @users =  User.where.not(id: current_user)
      @users_follow = current_user.followings
      if @users_follow.present?
        @users =  @users.where.not(id: @users_follow)
      end
      @users = @users.select('users.*', 'count(posts.id) AS posts').left_joins(:posts).group('users.id').order('posts desc').limit(5)

      @posts = Post.where.not(review: "bookmark").order(created_at: "DESC")
      @posts = @posts.where.not(user_id: current_user)
      if @users_follow.present?
        @posts = @posts.where.not(user_id: @users_follow)
      end
      @all = @posts.limit(20)
      @movie = @posts.where(category: "movie").limit(20)
      @tv = @posts.where(category: "tv").limit(20)
      @book = @posts.where(category: "book").limit(20)
      @comic = @posts.where(category: "comic").limit(20)
      @music = @posts.where(category: "music").limit(20)
	  end

  	def ajax_user_list
      if params[:q].present?
        @items = User.where('username LIKE ?', "%#{params[:q]}%")
      else
        @user  = User.find(current_user.id)
        @users = @user.followings
        @users_test = User.where(authority: "test")
        @posts = Post.where.not(review: "bookmark")
        @posts = @posts.where.not(user_id: @user)
        @posts = @posts.where.not(user_id: @users)
        @posts = @posts.where.not(user_id: @users_test)
        @posts = @posts.order(created_at: "DESC").limit(150)
      end
  	end

  	def configuration 		
  	end

  	def following		
      @user = User.find_by(username: params[:id]) 
  		@users = @user.followings
  	end

  	def ajax_following_list
  		@user = User.find_by(username: params[:id]) 
      @users = @user.followings
    	if params[:q].present?
       @items = @users.where('username LIKE ?', "%#{params[:q]}%")
      end
  	end

  	def follower
  		@user = User.find_by(username: params[:id]) 
      @users = @user.followers
  	end

  	def ajax_follower_list
  		@user = User.find_by(username: params[:id]) 
      @users = @user.followers
      if params[:q].present?
    	 @items = @users.where('username LIKE ?', "%#{params[:q]}%")
      end
  	end


    def policy     
    end

    def terms     
    end

    def contact     
    end

    def ajax_validate_username
      if params[:q].present?
        if User.where(username: params[:q]).exists?
          if current_user.username == params[:q]
            
          else
            @validation = "このidはすでに使われています"
            @check = false
          end
        else
          if params[:q].match(/\A[a-z\d_]{5,15}\z/i)
            @validation = "使用可能なidです"
            @check = true
          else
            @validation = "idは5文字以上15文字以内で,英字,数字と「_」が使用できます。スペースは使用できません。"
            @check = false
          end
        end
      end
    end

    def notifications
      @notifications = Notification.where(user_id: current_user.id).order(created_at: "DESC")
      @notifications_yes = @notifications.where(read: true)
      @notifications_no = @notifications.where(read: false)
    end

    private
      def notifications_update
        @notifications_no.update_all(read: true)
      end

end