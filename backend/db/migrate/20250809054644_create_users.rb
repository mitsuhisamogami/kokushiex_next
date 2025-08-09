class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :encrypted_password, null: false
      t.string :name
      t.boolean :is_guest, default: false, null: false

      t.timestamps
    end
  end
end
