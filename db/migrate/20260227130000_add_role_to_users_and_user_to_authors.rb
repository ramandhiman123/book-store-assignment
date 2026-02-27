class AddRoleToUsersAndUserToAuthors < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    add_reference :authors, :user, foreign_key: true, index: { unique: true }
  end
end
