class RelationshipsController < ApplicationController

   def create
    @user = User.find(params[:relationship][:following_id])
    current_user.follow!(@user)
    redirect_to "/users/#{@user.id}/collection"
  end

  def destroy
    @user = Relationship.find(params[:id]).following
    current_user.unfollow!(@user)
    redirect_to "/users/#{@user.id}/collection"
  end
end