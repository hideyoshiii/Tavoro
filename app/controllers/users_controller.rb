class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:policy, :terms, :contact]

	def collection
		@user = User.find(params[:id])	
    if @user
      @all = Post.where(user_id: @user.id).order(created_at: "DESC")

      @checkeds = @all.where.not(review: "bookmark")
      @checkeds_i = @checkeds.count
      @checkeds_movie = @checkeds.where(category: "movie")
      @checkeds_tv = @checkeds.where(category: "tv")
      @checkeds_book = @checkeds.where(category: "book")
      @checkeds_comic = @checkeds.where(category: "comic")
      @checkeds_music = @checkeds.where(category: "music")

      @bookmarks = @all.where(review: "bookmark")
      @bookmarks_i = @bookmarks.count
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

	def profile
		@user = User.find(params[:id])
	end

	  def user
	  end

  	def ajax_user_list
    	@items = User.where('name LIKE ?', "%#{params[:q]}%")
  	end

  	def configuration 		
  	end

  	def following		
  		@users = current_user.followings
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

end