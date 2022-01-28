# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  first_name :string           not null
#  last_name  :string           not null
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { create(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to allow_value("someone@example.com").for(:email) }
    it { is_expected.not_to allow_value("invalid").for(:email) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:course_users) }
    it { is_expected.to have_many(:courses).through(:course_users) }
    it { is_expected.to have_many(:enrollments).through(:course_users) }
  end
end
