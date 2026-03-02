class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  has_many :reviews, dependent: :destroy
  has_one :author_profile, class_name: "Author", dependent: :nullify, foreign_key: :user_id, inverse_of: :user
end
