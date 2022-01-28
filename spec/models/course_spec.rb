# == Schema Information
#
# Table name: courses
#
#  id          :bigint           not null, primary key
#  description :string           not null
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_courses_on_title  (title) UNIQUE
#
require 'rails_helper'

RSpec.describe Course, type: :model do
  let!(:course) { create(:course) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:title) }
  end

  describe 'associations' do
    it { is_expected.to have_one(:author) }
    it { is_expected.to have_many(:talents) }
  end
end
