class CreateFollowRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :follow_requests do |t|
      t.integer :requester_id
      t.integer :requesting_id

      t.timestamps
    end

    add_index :follow_requests, :requester_id
    add_index :follow_requests, :requesting_id
    add_index :follow_requests, [:requester_id, :requesting_id], unique: true
  end
end
