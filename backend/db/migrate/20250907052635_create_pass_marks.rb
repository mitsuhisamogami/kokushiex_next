class CreatePassMarks < ActiveRecord::Migration[7.2]
  def change
    create_table :pass_marks do |t|
      t.references :test, null: false, foreign_key: true, index: { unique: true }
      t.integer :required_score, null: false
      t.integer :required_practical_score, null: false
      t.integer :total_score, null: false

      t.timestamps
    end
  end
end
