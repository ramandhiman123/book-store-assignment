require "rails_helper"

RSpec.describe ReviewNotificationJob, type: :job do
  it "sends an email to each author of the reviewed book" do
    category = Category.create!(name: "Mystery")
    author_1 = Author.create!(name: "Author One")
    author_2 = Author.create!(name: "Author Two")
    book = Book.create!(title: "Whodunit", price: 12, category:)
    book.authors = [author_1, author_2]
    user = User.create!(email: "reader@example.com", password: "password")
    review = Review.create!(book:, user:, rating: 4, review: "Great twists!")

    ActionMailer::Base.deliveries.clear

    described_class.perform_now(review.id)

    expect(ActionMailer::Base.deliveries.size).to eq(2)
    subjects = ActionMailer::Base.deliveries.map(&:subject)
    expect(subjects).to all(eq("New review for Whodunit"))
  end
end
