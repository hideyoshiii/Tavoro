class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :invited_user, class_name: 'User', optional: true 
end
