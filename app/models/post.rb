class Post < ApplicationRecord
	belongs_to :user

	has_many :lists, dependent: :destroy

	has_many :likes, dependent: :destroy

end
