class UsersController < ApplicationController

	def collection
		@user = User.find(params[:id])
		@all = Post.where(user_id: @user.id).order('id DESC')
		@movie = @all.where(category: "movie").order('id DESC')
		@tv = @all.where(category: "tv").order('id DESC')
		@book = @all.where(category: "book").order('id DESC')
		@comic = @all.where(category: "comic").order('id DESC')
		@music = @all.where(category: "music").order('id DESC')
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

end