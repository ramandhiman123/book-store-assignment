class Review < ApplicationRecord
  belongs_to :user
  belongs_to :book
  has_many :review_replies, dependent: :destroy

  after_create_commit :broadcast_live_updates

  validates :rating,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 5
            }
  validates :review, presence: true, length: { minimum: 5 }

  private

  def broadcast_live_updates
    broadcast_prepend_to(
      book,
      target: "reviews",
      partial: "reviews/review",
      locals: { review: self, book: book }
    )

    broadcast_replace_to(
      book,
      target: "average_rating",
      partial: "books/average_rating",
      locals: { book: book }
    )
  end
end
