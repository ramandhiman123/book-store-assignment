require "rails_helper"
require "fileutils"
require "securerandom"

RSpec.describe "Pagination demo", type: :system do
  before do
    skip "chromedriver is not installed; skipping JS system spec" unless system("chromedriver --version > /dev/null 2>&1")
    driven_by(:selenium_chrome_headless)
  end

  it "shows pagination controls and captures screenshots", js: true do
    FileUtils.mkdir_p(Rails.root.join("tmp/screenshots"))
    suffix = SecureRandom.hex(4)
    category = Category.create!(name: "Paged Category #{suffix}")

    30.times do |i|
      Book.create!(title: "Paged Book #{suffix}-#{i}", price: 10 + i, category:, description: "Demo")
    end

    visit books_path(per_page: 12)
    expect(page).to have_text("Books")
    expect(page).to have_link("Next")

    save_screenshot(Rails.root.join("tmp/screenshots/books_index_page_1.png"), full: true)

    click_link "Next"
    expect(page).to have_link("Prev")

    save_screenshot(Rails.root.join("tmp/screenshots/books_index_page_2.png"), full: true)
  end
end
