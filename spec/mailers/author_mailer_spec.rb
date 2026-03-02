require "rails_helper"

RSpec.describe AuthorMailer, type: :mailer do
  it "renders review notification email" do
    category = Category.create!(name: "Drama")
    author = Author.create!(name: "Maya")
    user = User.create!(email: "critic@example.com", password: "password")
    book = Book.create!(title: "Stage Lights", price: 18, category:)
    review = Review.create!(book:, user:, rating: 5, review: "Outstanding work.")

    mail = described_class.review_notification(author, review)

    expect(mail.subject).to eq("New review for Stage Lights")
    expect(mail.to).to eq(["author-#{author.id}@example.com"])
    expect(mail.body.encoded).to include("Outstanding work.")
  end
end
