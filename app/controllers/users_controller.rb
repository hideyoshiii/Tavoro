class UsersController < ApplicationController
	def collection
		@user = User.find(params[:id])
		@all = Post.where(user_id: current_user.id).order('id DESC')
	end
end