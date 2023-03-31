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

  describe "case-insensitive name search, sorted a-z" do
    context "when successful" do
      it "returns all items that match the search" do
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
    end

    context "when unsuccessful" do
      it "returns a 200 error if no match found" do
        get "/api/v1/items/find_all?name=xxx"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(parsed).to be_a(Hash)
        expect(parsed.keys).to eq([:data])
        expect(parsed[:data]).to eq([])
      end

      it "can't search by name and price at the same time" do
        get "/api/v1/items/find_all?name=art&min_price=10.00"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
        expect(parsed[:errors]).to eq("Can't search by name and price")

        get "/api/v1/items/find_all?name=art&max_price=20.00"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
        expect(parsed[:errors]).to eq("Can't search by name and price")
      end
    end
  end

  describe "search all items greater than or equal to min_price" do
    context "when successful" do
      it "returns all items that match the search" do
        get "/api/v1/items/find_all?min_price=20.00"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(parsed).to be_a(Hash)
        expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][0][:id]).to eq(@oil.id.to_s)
        expect(parsed[:data][0][:type]).to eq('item')
        expect(parsed[:data][0][:attributes].size).to eq(4)
        expect(parsed[:data][0][:attributes][:name]).to eq(@oil.name)
        expect(parsed[:data][1][:attributes][:name]).to eq(@acrylic.name)
        expect(parsed[:data][2][:attributes][:name]).to eq(@paper.name)
        expect(parsed[:data][3][:attributes][:name]).to eq(@easel.name)
      end
    end

    context "when unsuccessful" do
      it "returns 400 error when min_price is less than 0" do
        get "/api/v1/items/find_all?min_price=-10.00"
        expect(response).to have_http_status(400)
        expect(parsed[:errors]).to eq("Price must be greater than 0")
      end
    end
  end

  describe "search all items that are less than or equal to max_price" do
    context "when successful" do
      it "returns all items that match the search" do
        get "/api/v1/items/find_all?max_price=20.00"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(parsed).to be_a(Hash)
        expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][0][:id]).to eq(@oil.id.to_s)
        expect(parsed[:data][0][:type]).to eq('item')
        expect(parsed[:data][0][:attributes].size).to eq(4)
        expect(parsed[:data][0][:attributes][:name]).to eq(@oil.name)
        expect(parsed[:data][1][:attributes][:name]).to eq(@acrylic.name)
        expect(parsed[:data][2][:attributes][:name]).to eq(@watercolor.name)
        expect(parsed[:data][3][:attributes][:name]).to eq(@eraser.name)
      end
    end

    context "when unsuccessful" do
      it "returns 400 error when max_price is less than 0" do
        get "/api/v1/items/find_all?max_price=-10.00"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
        expect(parsed[:errors]).to eq("Price must be greater than 0")
      end
    end
  end

  describe "search all items that are within max and min price range" do
    context "when successful" do
      it "returns all items that match the search" do
        get "/api/v1/items/find_all?min_price=20.00&max_price=100.00"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(parsed).to be_a(Hash)
        expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][0][:id]).to eq(@oil.id.to_s)
        expect(parsed[:data][0][:type]).to eq('item')
        expect(parsed[:data][0][:attributes].size).to eq(4)
        expect(parsed[:data][0][:attributes][:name]).to eq(@oil.name)
        expect(parsed[:data][1][:attributes][:name]).to eq(@acrylic.name)
        expect(parsed[:data][2][:attributes][:name]).to eq(@paper.name)
        expect(parsed[:data][3][:attributes][:name]).to eq(@easel.name)
      end
    end

    context "when unsuccessful" do
      it "returns 400 error when max_price or min_price is less than 0" do
        get "/api/v1/items/find_all?min_price=-10.00&max_price=20.00"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
        expect(parsed[:errors]).to eq("Price must be greater than 0")

        get "/api/v1/items/find_all?min_price=-30.00&max_price=-20.00"
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
        expect(parsed[:errors]).to eq("Price must be greater than 0")
      end
    end
  end
end