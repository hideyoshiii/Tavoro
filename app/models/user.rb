class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :generate_username

  validates :username, format: { with: /\A[a-z\d_]{5,15}\z/i }, on: :update, unless: :encrypted_password_changed?
  validates_uniqueness_of :username, on: :update, unless: :encrypted_password_changed?
  validates_presence_of :username, on: :update, unless: :encrypted_password_changed?

  after_create :send_welcome_mail
 
  def send_welcome_mail
    UserMailer.user_welcome_mail(self).deliver
  end

  has_many :posts, dependent: :destroy

  has_many :lists, dependent: :destroy

  has_many :notifications, dependent: :destroy

  has_many :invitations, dependent: :destroy


  has_many :following_relationships, foreign_key: "follower_id", class_name: "Relationship", dependent: :destroy

  has_many :followings, through: :following_relationships

  has_many :follower_relationships, foreign_key: "following_id", class_name: "Relationship", dependent: :destroy

  has_many :followers, through: :follower_relationships

  def following?(other_user)
    following_relationships.find_by(following_id: other_user.id)
  end

  def follow!(other_user)
    following_relationships.create!(following_id: other_user.id)
  end

  def unfollow!(other_user)
    following_relationships.find_by(following_id: other_user.id).destroy
  end


  has_many :requesting_follow_requests, foreign_key: "requester_id", class_name: "FollowRequest", dependent: :destroy

  has_many :requestings, through: :requesting_follow_requests

  has_many :requester_follow_requests, foreign_key: "requesting_id", class_name: "FollowRequest", dependent: :destroy

  has_many :requesters, through: :requester_follow_requests

  def requesting?(other_user)
    requesting_follow_requests.find_by(requesting_id: other_user.id)
  end

  def requester?(other_user)
    requester_follow_requests.find_by(requester_id: other_user.id)
  end

  def request!(other_user)
    requesting_follow_requests.create!(requesting_id: other_user.id)
  end

  def unrequest!(other_user)
    requesting_follow_requests.find_by(requesting_id: other_user.id).destroy
  end


  has_many :likes, dependent: :destroy

  has_attached_file :image, :styles => { :large => "400x400", :medium => "126x126", :thumb => "64x64>" }, :default_url => "user.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  

  def update_without_current_password(params, *options)
    params.delete(:current_password)
 
    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end
 
    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end


  private
  def generate_username
    loop do
      self.username = SecureRandom.hex(4)
      break unless User.where(username: username).exists?
    end
  end
  
end
