class AddReturnToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :returned, :boolean, default: false, null: false
    add_index :orders, :returned
  end

  def down
    remove_index :orders, :returned
    remove_column :orders, :returned
  end
end
