class AddRoleToEmployee < ActiveRecord::Migration[7.0]
  def change
    add_column :employees, :role, :string, null: false, default: 'warehouse'
  end

  def down
    remove_index :employees, :role if index_exists?(:employees, :role)
  end
end
