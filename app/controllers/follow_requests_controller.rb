class FollowRequestsController < ApplicationController

   def create
    @user_request = current_user
    @user = User.find(params[:follow_request][:requesting_id])
    if current_user.request!(@user)
      FollowRequestMailer.request_send_mail(@user, current_user).deliver_later
    end
  end

  def destroy
    @user = FollowRequest.find(params[:id]).requesting
    current_user.unrequest!(@user)
  end

  def approval
  	@user = User.find(params[:id])
  	if @user.follow!(current_user)
  		@user.unrequest!(current_user)
      FollowRequestMailer.request_approved_mail(@user, current_user).deliver_later
  	end
  end

  def unapproval	
  	@user = User.find(params[:id])
  	@user.unrequest!(current_user)
  end
  
end