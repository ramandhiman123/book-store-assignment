require "rails_helper"

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:reviews).dependent(:destroy) }
  it { is_expected.to have_one(:author_profile).class_name("Author").with_foreign_key(:user_id).dependent(:nullify) }
end
