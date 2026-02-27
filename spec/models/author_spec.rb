require "rails_helper"

RSpec.describe Author, type: :model do
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to have_many(:book_authors).dependent(:destroy) }
  it { is_expected.to have_many(:books).through(:book_authors) }
  it { is_expected.to validate_presence_of(:name) }
end
