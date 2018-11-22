class CreateInvitations < ActiveRecord::Migration[5.1]
  def change
    create_table :invitations do |t|
      t.references :user, foreign_key: true
      t.references :invited_user
      t.string :code
      t.boolean :used, default: false

      t.timestamps
    end
    add_foreign_key :invitations, :users, column: :invited_user_id
    add_index :invitations, :code, unique: true
  end
end
