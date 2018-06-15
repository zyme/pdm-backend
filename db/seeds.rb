# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user = User.new(
  email: 'test@test.com',
  password: 'testtest',
  password_confirmation: 'testtest'
)
user.skip_confirmation!
user.save!

Profile.new(name: 'Test', first_name: 'Test', last_name: 'Test')
