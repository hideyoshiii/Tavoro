class LikesController < ApplicationController

  def post
	@post = Post.find(params[:post_id])
	@likes = Like.where(post_id: @post.id)
	@likes_i = @likes.size
  end

  def create
    @post = Post.find(params[:post_id])
    if @like = Like.create(user_id: current_user.id, post_id: @post.id)   
    	Notification.create(user_id: @post.user.id, notified_by_id: current_user.id, notified_type: 'like', post_id: @post.id)
   	end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @like = Like.find_by(user_id: current_user.id, post_id: @post.id)
    @like.destroy   
  end

end