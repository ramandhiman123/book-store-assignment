class ReviewReply < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :review
  belongs_to :author

  validates :body, presence: true, length: { minimum: 2 }
  validate :author_must_belong_to_review_book

  after_create_commit :broadcast_live_reply

  private

  def author_must_belong_to_review_book
    return if review.blank? || author.blank?
    return if review.book.authors.exists?(id: author.id)

    errors.add(:author, "must be an author of this book")
  end

  def broadcast_live_reply
    broadcast_append_to(
      review.book,
      target: dom_id(review, :replies),
      partial: "review_replies/reply",
      locals: { reply: self }
    )
  end
end
