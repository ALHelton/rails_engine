require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many :items }
    it { should have_many :invoices }
  end

  describe "validations" do
    it { should validate_presence_of :name }
  end

  before do
    @merch5 = FactoryBot.create(:merchant, name: "Art Shop")
    
    @merch1 = FactoryBot.create(:merchant, name: "Artist Shop")
    @merch2 = FactoryBot.create(:merchant, name: "Practical Arts")
    @merch3 = FactoryBot.create(:merchant, name: "Jerry's Artarama")
    @merch4 = FactoryBot.create(:merchant, name: "Walmart")
    @merch6 = FactoryBot.create(:merchant, name: "Dick Blick")
  end

  describe "class methods" do
    it "find_by_name" do
      expect(Merchant.find_by_name("Art")).to eq(@merch5)
      expect(Merchant.find_by_name("Art")).to_not eq(@merch1)
    end
  end
end