require "rails_helper"

RSpec.describe "N+1 protections", type: :request do
  it "keeps index query count bounded as books increase" do
    category = Category.create!(name: "Bounded")
    author = Author.create!(name: "Shared Author")
    tag = Tag.create!(name: "shared-tag")

    3.times do |i|
      book = Book.create!(title: "Small #{i}", price: 10, category:)
      book.authors << author
      book.tags << tag
    end

    small_count = count_queries { get books_path, params: { per_page: 50 } }

    12.times do |i|
      book = Book.create!(title: "Large #{i}", price: 11, category:)
      book.authors << author
      book.tags << tag
    end

    large_count = count_queries { get books_path, params: { per_page: 50 } }

    expect(large_count - small_count).to be <= 3
  end

  it "keeps show query count bounded as reviews increase" do
    category = Category.create!(name: "ShowBounded")
    user = User.create!(email: "nplus1@example.com", password: "password")
    book = Book.create!(title: "Single Book", price: 8, category:)
    author = Author.create!(name: "One")
    tag = Tag.create!(name: "focused")
    book.authors << author
    book.tags << tag

    2.times do |i|
      Review.create!(book:, user:, rating: 4, review: "solid #{i}")
    end

    small_count = count_queries { get book_path(book) }

    10.times do |i|
      Review.create!(book:, user:, rating: 5, review: "great #{i}")
    end

    large_count = count_queries { get book_path(book) }

    expect(large_count - small_count).to be <= 3
  end
end
