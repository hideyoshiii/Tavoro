class MemosController < ApplicationController

  def new
  	@post = Post.find(params[:post_id])
  end

  def create
  	@post = Post.find(params[:post_id])
  	if @memo = Memo.create(user_id: current_user.id, post_id: @post.id, content: params[:content])
    	redirect_to "/post/#{@post.id}"
    else
    	redirect_to "/post/#{@post.id}"
    end   
  end

  def edit
  	@memo = Memo.find(params[:id])
    if !(current_user == @memo.user)
      redirect_to root_path
    end
  end

  def update
  	@memo = Memo.find(params[:id])
  	@post = Post.find(@memo.post.id)
  	if params[:content]
  		@memo.content = params[:content]
  	end
  	if @memo.save
      redirect_to "/post/#{@post.id}"
    else
      redirect_to "/post/#{@post.id}"
    end   
  end

  def destroy
  	@memo = Memo.find(params[:id])
  	@post = Post.find(@memo.post.id)
    if @memo.destroy
      redirect_to "/post/#{@post.id}"
    else
      redirect_to "/post/#{@post.id}"
    end   
  end

end