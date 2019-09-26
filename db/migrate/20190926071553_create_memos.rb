class CreateMemos < ActiveRecord::Migration[5.1]
  def change
    create_table :memos do |t|
      t.references :user, foreign_key: true
      t.references :post, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
