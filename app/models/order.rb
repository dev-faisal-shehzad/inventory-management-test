class Order < ApplicationRecord
  belongs_to :ships_to, class_name: 'Address'
  has_many :line_items, class_name: 'OrderLineItem'
  has_many :inventories

  scope :undeliverable_orders, -> { where(returned: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :fulfilled, -> { joins(:inventories).group('orders.id') }
  scope :not_fulfilled, -> { left_joins(:inventories).where(inventories: { order_id: nil }) }
  scope :fulfillable, lambda {
    not_fulfilled
      .joins(:line_items)
      .joins(<<~SQL)
        LEFT OUTER JOIN product_on_shelf_quantities
          ON order_line_items.product_id = product_on_shelf_quantities.product_id
         AND order_line_items.quantity <= product_on_shelf_quantities.quantity
      SQL
      .group(:id)
      .having(<<~SQL)
        COUNT(DISTINCT product_on_shelf_quantities.product_id) =
        COUNT(DISTINCT order_line_items.product_id)
      SQL
      .order(:created_at, :id)
  }

  def cost
    line_items.inject(Money.zero) do |acc, li|
      acc + li.cost
    end
  end

  def fulfilled?
    inventories.any?
  end

  # have sufficient stock on the shelf. However, the current logic only ensures that the total
  # number of products on the shelf matches the total number of line items, which might not
  # correctly validate if each line item can be individually fulfilled based on its quantity.
  #
  # To address this, ensure that each line item's quantity is checked against its available
  # stock independently, rather than relying on aggregated counts.

  def fulfillable?
    line_items.all?(&:fulfillable?)
  end

  def mark_as_returned
    raise 'Permission denied' unless employee.can_handle_returns?

    update(returned: true)
    restock_return_product
  end

  private

  def restock_return_product
    line_items.each do |line_item|
      product = line_item.product
      product.increment!(:on_shelf, line_item.quantity)
    end
  end
end
