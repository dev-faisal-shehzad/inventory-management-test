class AddFixedToAddress < ActiveRecord::Migration[7.0]
  def up
    add_column :addresses, :fixed, :boolean, default: false, null: false
  end

  def down
    remove_column :addresses, :fixed, :boolean
  end
end
