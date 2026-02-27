require "rails_helper"
require "fileutils"
require "securerandom"

RSpec.describe "Live review updates", type: :system do
  before do
    skip "chromedriver is not installed; skipping JS system spec" unless system("chromedriver --version > /dev/null 2>&1")
    driven_by(:selenium_chrome_headless)
  end

  it "shows new reviews and average rating updates without reload", js: true do
    FileUtils.mkdir_p(Rails.root.join("tmp/screenshots"))
    suffix = SecureRandom.hex(4)
    category = Category.create!(name: "Realtime #{suffix}")
    book = Book.create!(title: "Turbo Book #{suffix}", price: 22, category:, description: "Realtime updates")
    user = User.create!(email: "live-#{suffix}@example.com", password: "password")

    using_session(:viewer) do
      visit book_path(book)
      expect(page).to have_text("Average rating:")
      expect(page).to have_text("0.0 / 5")
      save_screenshot(Rails.root.join("tmp/screenshots/book_show_before_review.png"), full: true)
    end

    using_session(:reviewer) do
      perform_enqueued_jobs do
        visit new_user_session_path
        fill_in "Email", with: user.email
        fill_in "Password", with: "password"
        click_button "Sign in"

        visit book_path(book)
        fill_in "Rating", with: 5
        fill_in "Review text", with: "Outstanding realtime update!"
        click_button "Submit review"
        expect(page).to have_text("Outstanding realtime update!")
      end
    end

    using_session(:viewer) do
      expect(page).to have_text("Outstanding realtime update!")
      expect(page).to have_text("5.0 / 5")
      save_screenshot(Rails.root.join("tmp/screenshots/book_show_after_review.png"), full: true)
    end
  end
end
