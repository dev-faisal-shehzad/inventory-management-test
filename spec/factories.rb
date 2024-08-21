FactoryBot.define do
  factory :order do
    ships_to factory: :address
  end

  factory :order_line_item do
    product
    order
    quantity { 1 }
  end

  factory :address do
    recipient { 'Full name' }
    street_1 { '123 Main St' }
    city { 'New York City' }
    state { 'NY' }
    zip { '10001' }
    fixed { false }
  end

  factory :employee do
    sequence(:name) { |n| "Employee ##{n}" }
    sequence(:access_code) { |n| format('%05d', n) }
    role { Employee.roles.keys.sample }

    trait :warehouse do
      role { :warehouse }
    end

    trait :customer_service do
      role { :customer_service }
    end
  end

  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    price factory: :amount
    on_shelf { 0 }
  end

  factory :amount, class: Money do
    skip_create
    initialize_with { new(cents, currency) }

    transient do
      cents { 0 }
      currency { 'USD' }
    end

    trait :small do
      cents { 499 }
    end

    trait :medium do
      cents { 1299 }
    end

    trait :large do
      cents { 3299 }
    end
  end
end
