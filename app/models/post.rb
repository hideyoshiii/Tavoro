class Post < ApplicationRecord
	belongs_to :user

	has_many :list_items, dependent: :destroy

	has_many :likes, dependent: :destroy

	has_many :notifications, dependent: :destroy

end
