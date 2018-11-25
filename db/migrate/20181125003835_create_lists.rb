class CreateLists < ActiveRecord::Migration[5.1]
  def change
    create_table :lists do |t|
      t.references :user, foreign_key: true
      t.references :post, foreign_key: true
      t.string :title
      t.text :description
      t.boolean :private, default: false

      t.timestamps
    end
  end
end
