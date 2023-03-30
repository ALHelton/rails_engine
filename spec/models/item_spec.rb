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

  before do
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
  end

  describe "instance methods" do
    it "#single_item_invoices" do
      expect(@item1.single_item_invoices).to eq([@invoice, @invoice3])
      expect(@item2.single_item_invoices).to eq([])
    end
  end
end