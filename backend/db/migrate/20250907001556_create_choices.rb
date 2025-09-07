class CreateChoices < ActiveRecord::Migration[7.2]
  def change
    create_table :choices do |t|
      t.references :question, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :option_number, null: false
      t.boolean :is_correct, default: false, null: false

      t.timestamps
    end

    add_index :choices, [ :question_id, :option_number ], unique: true
  end
end
