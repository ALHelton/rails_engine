class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices

  validates :name, presence: true

  def self.find_by_name(name)
    where("name ILIKE ?", "%#{name}%")
      .order(:name)
      .first
  end
end