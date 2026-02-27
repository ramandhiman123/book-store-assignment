class CreateCategoriesAuthorsBooksAndReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :categories, :name, unique: true

    create_table :authors do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :books do |t|
      t.string  :title, null: false
      t.text    :description
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    create_table :book_authors do |t|
      t.references :book, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true

      t.timestamps
    end
    add_index :book_authors, %i[book_id author_id], unique: true

    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :review, null: false

      t.timestamps
    end
  end
end

