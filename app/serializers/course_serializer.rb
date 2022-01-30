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
class CourseSerializer < ActiveModel::Serializer
  attributes :id, :title, :description
end
