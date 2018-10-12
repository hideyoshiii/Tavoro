class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :image, :styles => { :large => "400x400", :medium => "126x126", :thumb => "64x64>" }, :default_url => "user04.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
