require "rails_helper"

RSpec.describe Category, type: :model do
  it { is_expected.to have_many(:books).dependent(:restrict_with_exception) }
  it { is_expected.to validate_presence_of(:name) }

  it "validates name uniqueness" do
    described_class.create!(name: "Fiction")
    duplicate = described_class.new(name: "Fiction")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:name]).to include("has already been taken")
  end
end
