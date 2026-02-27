require "rails_helper"

RSpec.describe Tag, type: :model do
  it { is_expected.to have_many(:book_tags).dependent(:destroy) }
  it { is_expected.to have_many(:books).through(:book_tags) }
  it { is_expected.to validate_presence_of(:name) }

  it "validates name uniqueness case-insensitively" do
    described_class.create!(name: "fantasy")
    duplicate = described_class.new(name: "FANTASY")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:name]).to include("has already been taken")
  end

  it "normalizes name before validation" do
    tag = described_class.create!(name: "  Fantasy  ")
    expect(tag.name).to eq("fantasy")
  end
end
