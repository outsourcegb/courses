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
class CourseUser < ApplicationRecord
  belongs_to :user
  belongs_to :course

  ROLE = {
    author: 'author',
    talent: 'talent',
  }.freeze

  validates_uniqueness_of :course_id, scope: :user_id,  message: 'already enrolled', conditions: lambda {
                                                                                                   where(role: 'talent')
                                                                                                 }
  validates_uniqueness_of :course_id, scope: :user_id,  message: 'already author', conditions: lambda {
                                                                                                 where(role: 'author')
                                                                                               }
end
