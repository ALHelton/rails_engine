require "rails_helper"

RSpec.describe Item, type: :model do
  describe "relationships" do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :merchant_id }

    it { should validate_numericality_of :unit_price }
  end

  
  describe "instance methods" do
    it "#single_item_invoices" do
        @merchant = create(:merchant)
        @customer = create(:customer)
        @item1 = create(:item, merchant_id: @merchant.id)
        @item2 = create(:item, merchant_id: @merchant.id)
        @item3 = create(:item, merchant_id: @merchant.id)
        @invoice = create(:invoice, merchant_id: @merchant.id, customer_id: @customer.id)
        @invoice2 = create(:invoice, merchant_id: @merchant.id, customer_id: @customer.id)
        @invoice3 = create(:invoice, merchant_id: @merchant.id, customer_id: @customer.id)
    
    
        @ii1 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item1.id)
        @ii2 = create(:invoice_item, invoice_id: @invoice2.id, item_id: @item2.id)
        @ii3 = create(:invoice_item, invoice_id: @invoice2.id, item_id: @item3.id)
        @ii1 = create(:invoice_item, invoice_id: @invoice3.id, item_id: @item1.id)
      
      expect(@item1.single_item_invoices).to eq([@invoice, @invoice3])
      expect(@item2.single_item_invoices).to eq([])
    end
  end

  describe "class methods" do

    before do
      @artshop = FactoryBot.create(:merchant, name: "Art Shop")
  
      @watercolor = FactoryBot.create(:item, name: "Watercolor Paint", unit_price: 10.00, merchant_id: @artshop.id)
      @oil = FactoryBot.create(:item, name: "Oil Paint", unit_price: 20.00, merchant_id: @artshop.id)
      @acrylic = FactoryBot.create(:item, name: "Acrylic Paint", unit_price: 20.00, merchant_id: @artshop.id)
      @eraser = FactoryBot.create(:item, name: "Eraser", unit_price: 4.00, merchant_id: @artshop.id)
      @paper = FactoryBot.create(:item, name: "Paper", unit_price: 60.00, merchant_id: @artshop.id)
      @easel = FactoryBot.create(:item, name: "Easel", unit_price: 100.00, merchant_id: @artshop.id)
    end

    it "find_by_name" do
      expect(Item.find_by_name("pAinT")).to eq([@acrylic, @oil, @watercolor])
      expect(Item.find_by_name("pAinT")).to_not eq([@oil, @watercolor, @acrylic])
      expect(Item.find_by_name("pAinT")).to_not eq([@paper])
    end

    it "find_by_price"
    it "find_above_price"
    it "find_below_price"
    it "find_between_price"
  end
end