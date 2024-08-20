class Employee < ApplicationRecord
  ROLES = {
    warehouse: 'warehouse',
    customer_service: 'customer_service'
  }.freeze

  enum role: ROLES

  validates :name, presence: true
  validates :access_code, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }
end
