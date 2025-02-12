FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    price { 9.99 }
  end
end