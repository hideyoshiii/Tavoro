class ChangeDatatypeWorkIdOfPosts < ActiveRecord::Migration[5.1]
  def change
  	change_column :posts, :work_id, :decimal, precision: 50, scale: 10
  end
end
