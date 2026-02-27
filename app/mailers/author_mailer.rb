class AuthorMailer < ApplicationMailer
  default from: ENV.fetch("SMTP_USERNAME", "no-reply@bookstore.local")

  def review_notification(author, review)
    @author = author
    @review = review
    @book = review.book
    @reviewer = review.user

    mail(
      to: author_email_address(author),
      subject: "New review for #{@book.title}"
    )
  end

  private

  def author_email_address(author)
    author.user&.email
  end
end
