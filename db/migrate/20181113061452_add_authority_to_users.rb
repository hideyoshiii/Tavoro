class AddAuthorityToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :authority, :string
  end
end
