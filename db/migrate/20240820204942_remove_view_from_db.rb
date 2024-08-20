class RemoveViewFromDb < ActiveRecord::Migration[6.0]
  def up
    Rake::Task['update_db:update_on_shelf'].invoke

    drop_view :product_on_shelf_quantities
  end

  def down
    create_view :product_on_shelf_quantities, sql_definition: <<-SQL
      SELECT p.id AS product_id,
             COUNT(i.product_id) AS quantity
      FROM products p
      LEFT JOIN inventories i ON (p.id = i.product_id AND i.status = 'on_shelf'::inventory_statuses)
      GROUP BY p.id
      ORDER BY p.id;
    SQL
  end
end
