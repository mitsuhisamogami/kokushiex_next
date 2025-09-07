class AddImageUrlToQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :image_url, :string
  end
end
