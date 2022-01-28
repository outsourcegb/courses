# == Schema Information
#
# Table name: course_users
#
#  id         :bigint           not null, primary key
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_course_users_on_course_id              (course_id)
#  index_course_users_on_course_id_and_user_id  (course_id,user_id) UNIQUE
#  index_course_users_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe CourseUser, type: :model do
  let(:user) { create(:user) }
  let(:course) { create(:course) }
  let(:course_user) { create(:course_user, user: user, course: course, role: :talent) }

  describe 'associations' do
    it { is_expected.to belong_to(:course) }
    it { is_expected.to belong_to(:user) }
  end
end
