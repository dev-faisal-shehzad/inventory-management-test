class Product < ApplicationRecord
  validates :name, presence: true
  monetize :price_cents
  has_many :inventory

  def in_stock_count
    inventory.on_shelf.count
  end

  def needed_inventory_count(id=nil)
    sql = <<-SQL
      SELECT COALESCE(SUM(order_line_items.quantity), 0) - COALESCE(products.on_shelf, 0)
      FROM order_line_items
      JOIN products ON products.id = order_line_items.product_id
      WHERE products.id = :product_id
      GROUP BY products.id
    SQL

    result = self.class.connection.select_value(
      ActiveRecord::Base.send(:sanitize_sql_array, [sql, { product_id: id }])
    )

    result.to_i
  end
end
