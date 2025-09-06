class CreateTestSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :test_sessions do |t|
      t.references :test, null: false, foreign_key: true
      t.string :name, null: false
      t.string :session_type, null: false

      t.timestamps
    end

    add_index :test_sessions, [ :test_id, :session_type ], unique: true
  end
end
