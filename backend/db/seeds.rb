# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Testデータの作成
puts "Creating Tests..."
tests = [
  { year: "第58回" },
  { year: "第57回" },
  { year: "第56回" }
]

tests.each do |test_attrs|
  test = Test.find_or_create_by!(year: test_attrs[:year])
  puts "  Created/Found Test: #{test.year}"
  
  # 各テストに午前・午後のセッションを作成
  ["morning", "afternoon"].each do |session_type|
    name = session_type == "morning" ? "午前" : "午後"
    session = TestSession.find_or_create_by!(
      test: test,
      session_type: session_type
    ) do |s|
      s.name = name
    end
    puts "    Created/Found TestSession: #{session.name} (#{session.session_type})"
  end
end

puts "Seed data created successfully!"
