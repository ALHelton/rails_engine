require "rails_helper"

describe "Merchants API", type: :request do
  before do
    create_list(:merchant, 3)
  end

  describe "#index" do
    before do 
      get "/api/v1/merchants"
      @parsed = JSON.parse(response.body, symbolize_names: true)
    end

    context "when successful" do
      it "GET all merchants" do
        expect(response).to be_successful

        expect(@parsed[:data].size).to eq(3)
        expect(@parsed[:data]).to be_an(Array)
        expect(@parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(@parsed[:data][0][:attributes][:name]).to eq(Merchant.first.name)
      end
    end
  end

  describe "#show" do
    context "when successful" do
      before do
        @merchant = Merchant.first
        get "/api/v1/merchants/#{@merchant.id}"
        @parsed = JSON.parse(response.body, symbolize_names: true)
      end

      it "GET one merchant" do
        expect(response).to be_successful

        expect(@parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(@parsed[:data][:id]).to eq(@merchant.id.to_s)
        expect(@parsed[:data][:type]).to eq('merchant')
        expect(@parsed[:data][:attributes][:name]).to eq(@merchant.name)
        expect(@parsed[:data][:attributes].size).to eq(1)
      end
    end

    context "when unsuccessful" do
      it "returns error message" do
        get "/api/v1/merchants/8923987297"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:error]).to eq("Couldn't find Merchant with 'id'=8923987297")
      end
    end
  end

  describe "Merchant Items" do
    context "when successful" do
      before do
        @merchant = create(:merchant)
        create_list(:item, 5, merchant_id: @merchant.id)
        get "/api/v1/merchants/#{@merchant.id}/items"
        @parsed = JSON.parse(response.body, symbolize_names: true)
      end

      it "GET all items for a given merchant ID" do
        expect(response).to be_successful
        expect(@parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(@parsed[:data][0][:attributes][:name]).to eq(@merchant.items.first.name)
        expect(@parsed[:data][0][:attributes][:description]).to eq(@merchant.items.first.description)
        expect(@parsed[:data][0][:attributes][:unit_price]).to eq(@merchant.items.first.unit_price)
        expect(@parsed[:data][0][:attributes][:merchant_id]).to eq(@merchant.id)
      end
    end
  end
end