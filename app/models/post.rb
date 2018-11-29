class Post < ApplicationRecord
	belongs_to :user

	has_many :lists_items, dependent: :destroy

	has_many :likes, dependent: :destroy

end
