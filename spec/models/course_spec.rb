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

  # describe 'associations' do
  #   it { should have_many(:course_users) }
  #   it { should have_many(:users).through(:course_users) }
  #   it { should have_many(:lessons) }
  # end
end
