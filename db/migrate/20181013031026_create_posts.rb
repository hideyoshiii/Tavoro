class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.integer :work_id
      t.string :category
      t.string :review
      t.text :description
      t.string :image_url
      t.string :preview_url
      t.string :favorite

      t.timestamps
    end
  end
end
