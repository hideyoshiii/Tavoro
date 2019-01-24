class RelationshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @user = User.find(params[:relationship][:following_id])
    if current_user.follow!(@user)
      Notification.create(user_id: @user.id, notified_by_id: current_user.id, notified_type: 'follow')
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).following
    current_user.unfollow!(@user)
  end
  
end