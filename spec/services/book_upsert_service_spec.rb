require "rails_helper"

RSpec.describe BookUpsertService, type: :service do
  it "upserts category, authors, tags, and book idempotently" do
    payload = [
      {
        category_name: "Fantasy",
        authors: ["A Writer"],
        tags: ["Epic", "Magic"],
        book: {
          title: "Dragon Song",
          description: "A dragon tale",
          price: 19.99
        }
      }
    ]

    service = described_class.new(payload)

    expect do
      service.call
      service.call
    end.to change(Book, :count).by(1)
      .and change(Category, :count).by(1)
      .and change(Author, :count).by(1)
      .and change(Tag, :count).by(2)

    book = Book.find_by!(title: "Dragon Song")
    expect(book.authors.map(&:name)).to eq(["A Writer"])
    expect(book.tags.map(&:name)).to match_array(%w[epic magic])
  end
end
