class Product < ApplicationRecord
  validates :name, presence: true
  monetize :price_cents
  has_many :inventory

  def in_stock_count
    inventory.on_shelf.count
  end

  def needed_inventory_count(id = nil)
    sql = <<~SQL
      SELECT GREATEST(
        SUM(
          COALESCE(
            order_line_items.quantity - (
              SELECT on_shelf
              FROM products
              WHERE products.id = ?), 0 )),0)
      FROM order_line_items
      LEFT OUTER JOIN inventories
        ON order_line_items.order_id = inventories.order_id
      WHERE order_line_items.product_id = ?
        AND inventories.order_id IS NULL
    SQL

    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, id, id])
    result = self.class.connection.select_value(sanitized_sql)

    result.to_i
  end

  # def needed_inventory_count(id = nil)
  #   id ||= self.id
  #   return 0 unless id.present?

  #   # Subquery to get the on-shelf quantity for the given product
  #   on_shelf_quantity = Product.select(:on_shelf).find_by(id:).try(:on_shelf).to_i

  #   # Sum of ordered quantities for the product where the order is not in the inventories table
  #   ordered_quantity = OrderLineItem
  #                      .left_outer_joins(:order)
  #                      .where(product_id: id)
  #                      .where.not(order_id: Inventory.select(:order_id))
  #                      .sum(:quantity)

  #   # Calculate the needed inventory count
  #   [ordered_quantity - on_shelf_quantity, 0].max
  # end
end
