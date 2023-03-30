class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: true
  validates :merchant_id, presence: true

  def single_item_invoices
    invoices.joins(:items)
      .group(:id)
      .having("count(items.id) =1")
  end

  def self.find_by_name(name)
    where("name ILIKE ?", "%#{name}%")
    .order(name: :asc)
  end
end