require "rails_helper"

RSpec.describe Book, type: :model do
  it { is_expected.to belong_to(:category) }
  it { is_expected.to have_many(:reviews).dependent(:destroy) }
  it { is_expected.to have_many(:authors).through(:book_authors) }
  it { is_expected.to have_many(:tags).through(:book_tags) }
  it { is_expected.to have_one_attached(:cover_photo) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

  describe "#average_rating" do
    it "returns rounded average" do
      category = Category.create!(name: "Fiction")
      user = User.create!(email: "reader@example.com", password: "password")
      book = described_class.create!(title: "Sample", price: 10, category:)
      book.reviews.create!(user:, rating: 4, review: "good one")
      book.reviews.create!(user:, rating: 5, review: "great one")

      expect(book.average_rating).to eq(4.5)
    end
  end
end
