require "rails_helper"

RSpec.describe Review, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:book) }

  it { is_expected.to validate_numericality_of(:rating).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5) }
  it { is_expected.to validate_presence_of(:review) }
  it { is_expected.to validate_length_of(:review).is_at_least(5) }
end
