class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:policy, :terms, :contact]
  after_action :notification_update, only: [:notification]

	def posts
		@user = User.find_by(username: params[:id])	
    if @user
      @all = Post.where(user_id: @user.id).order(created_at: "DESC")

      @checkeds = @all.where.not(review: "bookmark")
      @checkeds_i = @checkeds.size
      @checkeds_movie = @checkeds.where(category: "movie")
      @checkeds_tv = @checkeds.where(category: "tv")
      @checkeds_book = @checkeds.where(category: "book")
      @checkeds_comic = @checkeds.where(category: "comic")
      @checkeds_music = @checkeds.where(category: "music")

      @bookmarks = @all.where(review: "bookmark")
      @bookmarks_i = @bookmarks.size
      @bookmarks_movie = @bookmarks.where(category: "movie")
      @bookmarks_tv = @bookmarks.where(category: "tv")
      @bookmarks_book = @bookmarks.where(category: "book")
      @bookmarks_comic = @bookmarks.where(category: "comic")
      @bookmarks_music = @bookmarks.where(category: "music")
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

    private
      def notification_update
        @notifications_no.update_all(read: true)
      end


end