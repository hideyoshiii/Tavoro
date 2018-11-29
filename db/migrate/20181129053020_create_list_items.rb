class CreateListItems < ActiveRecord::Migration[5.1]
  def change
    create_table :list_items do |t|
      t.references :list, foreign_key: true
      t.references :post, foreign_key: true

      t.timestamps
    end
  end
end
