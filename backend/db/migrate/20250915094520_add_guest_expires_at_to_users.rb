class AddGuestExpiresAtToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :guest_expires_at, :datetime

    # ゲストユーザーの期限切れ検索を高速化するインデックス
    add_index :users, [ :is_guest, :guest_expires_at ],
              where: "is_guest = true",
              name: "index_users_on_guest_and_expires"

    # 通常ユーザーのemail検索を高速化するインデックス
    add_index :users, :email,
              where: "is_guest = false",
              name: "index_users_on_email_for_regular"
  end
end
