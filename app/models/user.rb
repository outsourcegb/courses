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
class User < ApplicationRecord
  validates :email, :first_name, :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email?
  validates :email, uniqueness: true

  has_many :course_users, dependent: :nullify
  has_many :courses, -> { where(course_users: { role: :author }) }, through: :course_users, source: :course
  has_many :enrollments, -> { where(course_users: { role: :talent }) }, through: :course_users, source: :course

  def delete_enrollments
    enrollments.destroy_all
  end
end
