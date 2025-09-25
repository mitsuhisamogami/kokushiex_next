class AddRoleToUsers < ActiveRecord::Migration[7.2]
  def up
    # roleカラムを追加（デフォルト値は1=regular）
    add_column :users, :role, :integer, default: 1, null: false
    add_index :users, :role

    # 既存のis_guest=trueのユーザーをrole=0(guest)に移行
    User.reset_column_information
    User.where(is_guest: true).update_all(role: 0)
  end

  def down
    remove_index :users, :role
    remove_column :users, :role
  end
end
