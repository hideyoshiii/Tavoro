class AddApiToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :api, :string
  end
end
