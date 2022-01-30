# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Course.destroy_all
User.destroy_all

puts "Creating records..."

100.times.each do |i|
  user = User.create!(
    first_name: "#{i}_" +Faker::Name.first_name,
    last_name: "#{i}_" +Faker::Name.last_name,
    email: "#{i}_" + Faker::Internet.email,
    phone: Faker::PhoneNumber.phone_number,
    )

  course = Course.create!(
    title: Faker::Educator.course_name + "_#{i}",
    description: Faker::Lorem.paragraph
  )

  CourseUser.create!(
    user: user,
    course: course,
    role: :author
  )
end

Course.all.each do |course|
  rand(1..5).times do
    user = User.all.sample

    user_exists = course.course_users.where(user: user).exists?

    next if user_exists

    CourseUser.create!(
      user: user,
      course: course,
      role: :talent
    )
  end
end

puts 'Done!'

