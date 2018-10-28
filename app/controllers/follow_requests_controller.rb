class FollowRequestsController < ApplicationController

   def create
    @user = User.find(params[:follow_request][:requesting_id])
    current_user.request!(@user)
  end

  def destroy
    @user = FollowRequest.find(params[:id]).requesting
    current_user.unrequest!(@user)
  end

  def approval
  	@user = User.find(params[:id])
  	if @user.follow!(current_user)
  		@user.unrequest!(current_user)
  	end
  end

  def unapproval	
  	@user = User.find(params[:id])
  	@user.unrequest!(current_user)
  end
  
end