require "rails_helper"

RSpec.describe "Books pagination", type: :request do
  let!(:category_a) { Category.create!(name: "Fiction") }
  let!(:category_b) { Category.create!(name: "History") }
  let!(:tag) { Tag.create!(name: "Featured") }

  let!(:history_only_book) { Book.create!(title: "History Special", price: 20, category: category_b) }
  let!(:fiction_only_book) { Book.create!(title: "Fiction Special", price: 25, category: category_a) }

  before do
    20.times do |i|
      book = Book.create!(title: "Book #{i}", price: 10, category: i.even? ? category_a : category_b)
      book.tags << tag if i % 3 == 0
    end
  end

  it "paginates books with limit and offset" do
    get "/books", params: { page: 2, per_page: 5 }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Prev")
    expect(response.body).to include("Next")
  end

  it "filters by category" do
    get "/books", params: { category_id: category_b.id }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("History Special")
    expect(response.body).not_to include("Fiction Special")
  end

  it "filters by tag name" do
    get "/books", params: { tag: "featured" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("featured")
  end

  it "caps per_page at 50" do
    get "/books", params: { per_page: 999 }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Books")
  end
end
