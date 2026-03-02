require "rails_helper"

RSpec.describe "Creator::Books", type: :request do
  let!(:category) { Category.create!(name: "Creator Category") }
  let!(:reader) { User.create!(email: "reader-role@example.com", password: "password") }
  let!(:author_user) { User.create!(email: "author-role@example.com", password: "password") }
  let!(:author_profile) { Author.create!(name: "Author User", user: author_user) }

  describe "GET /author/books/new" do
    it "redirects non-authenticated users" do
      get new_author_book_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "blocks reader users" do
      sign_in reader
      get new_author_book_path

      expect(response).to redirect_to(root_path)
    end

    it "allows author users" do
      sign_in author_user
      get new_author_book_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Add a New Book")
    end
  end

  describe "POST /author/books" do
    it "creates a book for author users and links author profile" do
      sign_in author_user

      expect do
        post author_books_path, params: {
          book: {
            title: "Author Created Book",
            description: "A new author-created book",
            price: 12.75,
            category_id: category.id,
            tag_list: "new, featured"
          }
        }
      end.to change(Book, :count).by(1)

      book = Book.find_by!(title: "Author Created Book")
      expect(book.authors.pluck(:user_id)).to include(author_user.id)
      expect(book.tags.pluck(:name)).to match_array(%w[new featured])
    end
  end
end
