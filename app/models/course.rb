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
class Course < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :description, presence: true

  has_one :course_user, dependent: :nullify
  has_many :course_users, dependent: :nullify

  has_one :author, -> { where("course_users.role = ?", :author) }, through: :course_user, source: :user
  has_many :talents, -> { where("course_users.role = ?", :talent) }, through: :course_users, source: :user
end
