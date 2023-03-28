FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    description { Faker::TvShows::TwinPeaks.quote }
    unit_price { Faker::Commerce.price }
    association :merchant
  end
end
