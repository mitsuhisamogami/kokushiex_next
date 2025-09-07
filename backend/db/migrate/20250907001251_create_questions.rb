class CreateQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :questions do |t|
      t.references :test_session, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :question_number, null: false
      t.integer :correct_choice_id
      t.string :category
      t.text :explanation

      t.timestamps
    end

    add_index :questions, [ :test_session_id, :question_number ], unique: true
  end
end
