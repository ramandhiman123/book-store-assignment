class RemoveRoleFromUsers < ActiveRecord::Migration[7.1]
  def up
    remove_column :users, :role, :integer if column_exists?(:users, :role)
  end

  def down
    return if column_exists?(:users, :role)

    add_column :users, :role, :integer, null: false, default: 0
  end
end
