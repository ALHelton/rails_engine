class Item < ApplicationRecord
  belongs_to :merchant

  validates :name, :description, :unit_price, presence: true
end