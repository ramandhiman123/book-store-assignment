require "rails_helper"

RSpec.describe "Reviews", type: :request do
  let!(:category) { Category.create!(name: "Sci-Fi") }
  let!(:book) { Book.create!(title: "Dune-ish", price: 15, category:) }
  let!(:user) { User.create!(email: "reviewer@example.com", password: "password") }

  describe "POST /books/:book_id/reviews" do
    let(:params) do
      {
        review: {
          rating: 5,
          review: "Really enjoyed this read."
        }
      }
    end

    it "returns unauthorized for unauthenticated users via middleware" do
      post book_reviews_path(book), params: params

      expect(response).to have_http_status(:unauthorized)
    end

    it "creates review and enqueues notification job for authenticated users" do
      sign_in user

      expect do
        post book_reviews_path(book), params: params
      end.to change(Review, :count).by(1)
        .and have_enqueued_job(ReviewNotificationJob)

      expect(response).to have_http_status(:found)
    end
  end
end
