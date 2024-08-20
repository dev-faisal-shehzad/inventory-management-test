class AddShellToProduct < ActiveRecord::Migration[6.0]
  def up
    add_column :products, :on_shelf, :integer, default: 0, null: false
  end

  def down
    remove_column :products, :on_shelf
  end
end
