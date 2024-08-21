class OrderLineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  validates :quantity, numericality: { greater_than: 0 }

  before_save :adjust_shelf_quantity

  def cost
    quantity * product.price
  end

  def on_shelf_quantity
    product&.on_shelf || 0
  end

  def fulfillable?
    on_shelf_quantity >= quantity
  end

  def adjust_shelf_quantity
    if persisted?
      # # Subtract the old quantity from on_shelf (before update)
      # product.increment!(:on_shelf, quantity_was)
      # # Add the new quantity to on_shelf (after update)
      # product.decrement!(:on_shelf, quantity)
    else
      # When the line item is being created
      product.update!(on_shelf: product.on_shelf + quantity)
    end
  end
end
