class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:policy, :terms, :contact]
  after_action :notification_update, only: [:notification]

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
	  end

  	def ajax_user_list
    	@user = User.find_by(username: params[:q])
  	end

  	def configuration 		
  	end

  	def following		
  		@users = current_user.followings
      @users_public = @users.where(authority: "public")
      @users_public_i = @users_public.size
      @users_normal = @users.where(authority: nil)
      @users_normal_i = @users_normal.size
  	end

  	def ajax_following_list
  		@users = current_user.followings
    	@items = @users.where('name LIKE ?', "%#{params[:q]}%")
  	end

  	def follower
  		@users = current_user.followers
  	end

  	def ajax_follower_list
  		@users = current_user.followers
    	@items = @users.where('name LIKE ?', "%#{params[:q]}%")
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

    def notification
      @notifications = Notification.where(user_id: current_user.id)
      @notifications_yes = @notifications.where(read: true)
      @notifications_no = @notifications.where(read: false)
    end

    def invitation  
      @invitation = Invitation.new  

      @invitations = Invitation.where(user_id: current_user.id).order(created_at: "DESC")
    end

    private
      def notification_update
        @notifications_no.update_all(read: true)
      end


end