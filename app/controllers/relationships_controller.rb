class RelationshipsController < ApplicationController

   def create
    @user = User.find(params[:relationship][:following_id])
    if @user.authority == "public"
      current_user.follow!(@user)
      @info = ""
      Notification.create(user_id: @user.id,notified_by_id: current_user.id,notified_type: 'follow')
  	else
  		@followings_all = current_user.followings
  		if @followings_all.where(authority: nil).size < 20
  			current_user.follow!(@user)
  			@info = ""
        Notification.create(user_id: @user.id,notified_by_id: current_user.id,notified_type: 'follow')
  		else
  			@info = "フォローできる人数が上限に達しています"
  		end
  	end
  end

  def destroy
    @user = Relationship.find(params[:id]).following
    current_user.unfollow!(@user)
  end
  
end