class AddPostRefToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_reference :notifications, :post, foreign_key: true
  end
end
