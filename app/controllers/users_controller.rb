class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:notifications]
  after_action :notifications_update, only: [:notifications]

  def posts
    @user = User.find_by(username: params[:id]) 
    if @user
      @alls = Post.where(user_id: @user.id).order(created_at: "DESC")

      @done_i = @alls.where.not(review: "doing").where.not(review: "bookmark").size
      @doing_i = @alls.where(review: "doing").size
      @want_i = @alls.where(review: "bookmark").size

      if params[:type].present?
        if params[:type] == "doing"
          @type = "doing"
        end
        if params[:type] == "want"
          @type = "want"
        end
      else
        @type = "done"
      end

      if @type == "done"
        @all = @alls.where.not(review: "doing").where.not(review: "bookmark")
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
      if @type == "doing"
        @all = @alls.where(review: "doing")
        @movie = @all.where(category: "movie")
        @tv = @all.where(category: "tv")
        @book = @all.where(category: "book")
        @comic = @all.where(category: "comic")
        @music = @all.where(category: "music")
      end
      if @type == "want"
        @all = @alls.where(review: "bookmark")
        @movie = @all.where(category: "movie")
        @tv = @all.where(category: "tv")
        @book = @all.where(category: "book")
        @comic = @all.where(category: "comic")
        @music = @all.where(category: "music")
      end

    end
  end

  def follow_request
    @user = current_user
    @users_requester = current_user.requesters
    @users_requesting = current_user.requestings
  end


  def user
    @user_ranking = User.find(Post.group(:user_id).order('count(user_id) desc').limit(20).pluck(:user_id))
  end

	def ajax_user_list
    if params[:q].present?
      @items = User.where('username LIKE ?', "%#{params[:q]}%")
    else
      @user_ranking = User.find(Post.group(:user_id).order('count(user_id) desc').limit(20).pluck(:user_id))
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
    @notifications_no = @notifications.where(read: false)
  end

  private
    def notifications_update
      @notifications_no.update_all(read: true)
    end

end