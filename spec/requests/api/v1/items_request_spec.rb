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

  describe "#show" do
    before do
      @item = Item.first
      get "/api/v1/items/#{@item.id}"
      @parsed = JSON.parse(response.body, symbolize_names: true)
    end

    context "when successful" do
      it "GET one item" do
        expect(response).to be_successful

        expect(@parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(@parsed[:data][:id]).to eq(@item.id.to_s)
        expect(@parsed[:data][:type]).to eq('item')
        expect(@parsed[:data][:attributes][:name]).to eq(@item.name)
        expect(@parsed[:data][:attributes][:description]).to eq(@item.description)
        expect(@parsed[:data][:attributes][:unit_price]).to eq(@item.unit_price)
        expect(@parsed[:data][:attributes][:merchant_id]).to eq(@item.merchant_id)
        expect(@parsed[:data][:attributes][:unit_price]).to be_a(Float)
        expect(@parsed[:data][:attributes].size).to eq(4)
      end
    end

    context "when unsuccessful" do
      it "returns error message" do
        get "/api/v1/items/8923987297"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(404)
        expect(parsed[:error]).to eq("Couldn't find Item with 'id'=8923987297")
      end
    end
  end

  describe "#create" do
    context "when successful" do
      before do
        merchant = Merchant.first
        item_params = ({
                      name: "Shiny Itemy Item",
                      description: "It does a lot of things real good",
                      unit_price: 40.00,
                      merchant_id: merchant.id
                      })
        headers = {"CONTENT_TYPE" => "application/json"}
        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
        @created_item = Item.last
        @parsed = JSON.parse(response.body, symbolize_names: true)
      end

      it "creates a new item" do
        expect(response).to be_successful
        expect(@parsed[:data][:type]).to eq('item')
        expect(@parsed[:data][:attributes][:name]).to eq(@created_item.name)
        expect(@parsed[:data][:attributes][:description]).to eq(@created_item.description)
        expect(@parsed[:data][:attributes][:unit_price]).to eq(@created_item.unit_price)
        expect(@parsed[:data][:attributes][:merchant_id]).to eq(@created_item.merchant_id)
        expect(@parsed[:data][:attributes][:unit_price]).to be_a(Float)
        expect(@parsed[:data][:attributes].size).to eq(4)
      end
    end

    # context "when unsuccessful" do
    #   it "returns error if any attribute is missing" do
    #     merchant = Merchant.first
        
    #     item_params_1 = ({
    #       name: "Shiny Itemy Item",
    #       description: "It does a lot of things real good",
    #       unit_price: 40.00,
    #       merchant_id: merchant.id
    #       })
    #     item_params_2 = ({
    #       name: "Shiny Itemy Item",
    #       description: "It does a lot of things real good",
    #       unit_price: 40.00,
    #       merchant_id: merchant.id
    #       })
    #     headers = {"CONTENT_TYPE" => "application/json"}
    #     post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    #     parsed = JSON.parse(response.body, symbolize_names: true)
    #   end
    # end
  end
end