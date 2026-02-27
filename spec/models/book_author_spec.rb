require "rails_helper"

RSpec.describe BookAuthor, type: :model do
  it { is_expected.to belong_to(:book) }
  it { is_expected.to belong_to(:author) }
end
