require "rails_helper"

RSpec.describe "Creator::Categories", type: :request do
  let!(:reader) { User.create!(email: "cat-reader@example.com", password: "password") }
  let!(:author_user) { User.create!(email: "cat-author@example.com", password: "password") }
  let!(:author_profile) { Author.create!(name: "Category Author", user: author_user) }

  it "prevents reader users from creating categories" do
    sign_in reader

    expect do
      post author_categories_path, params: { category: { name: "Blocked Category" } }
    end.not_to change(Category, :count)

    expect(response).to redirect_to(root_path)
  end

  it "allows author users to create categories" do
    sign_in author_user

    expect do
      post author_categories_path, params: { category: { name: "Author Category" } }
    end.to change(Category, :count).by(1)

    expect(response).to redirect_to(author_dashboard_path)
  end
end
