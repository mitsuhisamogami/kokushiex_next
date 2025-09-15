User.seed(:id, [
  {
    id: 1,
    email: "admin@example.com",
    password: "password123",
    password_confirmation: "password123",
    name: "管理者ユーザー",
    is_guest: false
  },
  {
    id: 2,
    email: "user@example.com",
    password: "password123",
    password_confirmation: "password123",
    name: "テストユーザー",
    is_guest: false
  }
])
