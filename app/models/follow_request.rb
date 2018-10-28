class FollowRequest < ApplicationRecord
	belongs_to :requester, class_name: "User"
    belongs_to :requesting, class_name: "User"
    validates :requester_id, presence: true
    validates :requesting_id, presence: true
end
