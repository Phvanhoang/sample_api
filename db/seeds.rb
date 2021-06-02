User.create!(name: "Admin",
  email: "admin@gmail.com",
  password: "admin123",
  password_confirmation: "admin123",
  admin: true)

100.times do |n|
name = Faker::Name.name
email = "user-#{n+1}@gmail.com"
password = "password"
User.create!(name: name,
    email: email,
    password: password,
    password_confirmation: password)
end
