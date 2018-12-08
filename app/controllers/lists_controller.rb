class ListsController < ApplicationController
  
  def create_profile
    @post = Post.find(params[:id].to_s) 
    @list = List.find_by(user_id: current_user.id, title: "プロフィール")
    if @list.present?
      @list_items = ListItem.where(list_id: @list.id)
      @list_items.destroy_all
    else
      @list = List.create(user_id: current_user.id, title: "プロフィール")
    end
    @list_item = ListItem.create(list_id: @list.id, post_id: @post.id)
  end

  def destroy_profile
    @post = Post.find(params[:id].to_s) 
    @list = List.find_by(user_id: current_user.id, title: "プロフィール")
    @list_item = ListItem.find_by(list_id: @list.id, post_id: @post.id)
    @list_item.destroy 
  end

  def create_favorite
    @post = Post.find(params[:id].to_s) 
    @list = List.find_by(user_id: current_user.id, title: "お気に入り")
    if @list.blank?
      @list = List.create(user_id: current_user.id, title: "お気に入り")
    end
    @list_item = ListItem.create(list_id: @list.id, post_id: @post.id)
  end

  def destroy_favorite
    @post = Post.find(params[:id].to_s) 
    @list = List.find_by(user_id: current_user.id, title: "お気に入り")
    @list_item = ListItem.find_by(list_id: @list.id, post_id: @post.id)
    @list_item.destroy 
  end

end