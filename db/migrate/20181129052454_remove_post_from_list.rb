class RemovePostFromList < ActiveRecord::Migration[5.1]
  def change
    remove_reference :lists, :post, foreign_key: true
  end
end
