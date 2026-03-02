class ReviewNotificationJob < ApplicationJob
  queue_as :default

  def perform(review_id)
    review = Review.includes(:user, book: :authors).find(review_id)
    book = review.book
    book.authors.includes(:user).each do |author|
      next if author.user&.email.blank?

      AuthorMailer.review_notification(author, review).deliver_now
    end
  end
end
