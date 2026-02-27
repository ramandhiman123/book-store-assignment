class AuthorMailerPreview < ActionMailer::Preview
  def review_notification
    category = Category.first || Category.create!(name: "Preview Category")
    author = Author.first || Author.create!(name: "Preview Author")
    user = User.first || User.create!(email: "preview-reviewer@example.com", password: "password")
    book = Book.first || Book.create!(title: "Preview Book", price: 9.99, category: category)

    unless book.authors.exists?(author.id)
      book.authors << author
    end

    review = Review.order(created_at: :desc).first || Review.create!(
      user: user,
      book: book,
      rating: 5,
      review: "Preview review message"
    )

    AuthorMailer.review_notification(author, review)
  end
end
