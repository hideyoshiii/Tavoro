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
end