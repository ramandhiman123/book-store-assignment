class Author < ApplicationRecord
  belongs_to :user, optional: true, inverse_of: :author_profile
  has_many :book_authors, dependent: :destroy
  has_many :books, through: :book_authors

  validates :name, presence: true
  validates :user_id, uniqueness: true, allow_nil: true
end
