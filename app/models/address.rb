class Address < ApplicationRecord
  has_many :orders, foreign_key: 'ships_to_id', dependent: :nullify

  validates :recipient, :street_1, :city, :state, :zip, presence: true

  def self.list_of_returned_order_customers
    raise 'Permission Denied' unless current_user.can_view_returned_orders?

    Address.includes(:orders).where(orders: { returned: true }).distinct
  end

  def mark_as_fixed
    update(fixed: true)
  end
end
