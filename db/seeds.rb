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

users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content: content) }
end

users = User.all
user = users.first
following = users[2..20]
followers = users[3..15]
following.each{|followed| user.follow(followed)}
followers.each{|follower| follower.follow(user)}
