class CreateTests < ActiveRecord::Migration[7.2]
  def change
    create_table :tests do |t|
      t.string :year, null: false
      t.timestamps
    end

    add_index :tests, :year, unique: true
  end
end
