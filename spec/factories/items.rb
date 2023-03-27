FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    description { Faker::Shakespeare.as_you_like_it_quote }
    unit_price { Faker::Commerce.price }
    association :merchant
  end
end
