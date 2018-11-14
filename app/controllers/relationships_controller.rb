class RelationshipsController < ApplicationController

   def create
    @user = User.find(params[:relationship][:following_id])
    if @user.authority == "public"
    	current_user.follow!(@user)
    	@info = ""
	else
		@followings_all = current_user.followings
		if @followings_all.where(authority: nil).size < 20
			current_user.follow!(@user)
			@info = ""
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