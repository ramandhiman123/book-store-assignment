class CreateReviewReplies < ActiveRecord::Migration[7.1]
  def change
    create_table :review_replies do |t|
      t.references :review, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
