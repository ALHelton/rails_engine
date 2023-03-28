require "rails_helper"

describe "Items API", type: :request do
  before do
    create_list(:item, 5)
  end

  describe "#index" do
    before do 
      @item = Item.first
      get "/api/v1/items"
      @parsed = JSON.parse(response.body, symbolize_names: true)
    end

    context "when successful" do
      it "GET all items" do
        expect(response).to be_successful
        expect(@parsed[:data].count).to eq(5)
        expect(@parsed[:data]).to be_an(Array)
        expect(@parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(@parsed[:data][0][:attributes][:name]).to eq(@item.name)
        expect(@parsed[:data][0][:attributes][:description]).to eq(@item.description)
        expect(@parsed[:data][0][:attributes][:unit_price]).to eq(@item.unit_price)
        expect(@parsed[:data][0][:attributes][:merchant_id]).to eq(@item.merchant_id)
      end
    end
  end
end