require "rails_helper"

describe "Items Search API", type: :request do
  before do
    @artshop = FactoryBot.create(:merchant, name: "Art Shop")

    @watercolor = FactoryBot.create(:item, name: "Watercolor Paint", unit_price: 10.00, merchant_id: @artshop.id)
    @oil = FactoryBot.create(:item, name: "Oil Paint", unit_price: 20.00, merchant_id: @artshop.id)
    @acrylic = FactoryBot.create(:item, name: "Acrylic Paint", unit_price: 20.00, merchant_id: @artshop.id)
    @eraser = FactoryBot.create(:item, name: "Eraser", unit_price: 4.00, merchant_id: @artshop.id)
    @paper = FactoryBot.create(:item, name: "Paper", unit_price: 60.00, merchant_id: @artshop.id)
    @easel = FactoryBot.create(:item, name: "Easel", unit_price: 100.00, merchant_id: @artshop.id)
  end

  context "when successful" do
    it "gets all case-insensitive items that match a search term, sorted a-z" do
      get "/api/v1/items/find_all?name=paint"
      parsed = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful
      expect(parsed[:data].size).to eq(3)
      expect(parsed[:data]).to be_an(Array)
      expect(parsed[:data][0][:type]).to eq("item")
      expect(parsed[:data][0][:attributes][:name]).to eq(@acrylic.name)
      expect(parsed[:data][1][:attributes][:name]).to eq(@oil.name)
      expect(parsed[:data][2][:attributes][:name]).to eq(@watercolor.name)
    end

    # describe "min_price"
    it "gets all items that are equal or greater than given price"

    # describe "max_price"
    it "gets all items that are equal or less than given price"

    it "gets all items that are within max and min price range"

  end
end