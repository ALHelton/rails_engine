require "rails_helper"

describe "Merchants API", type: :request do
  before do
    create_list(:merchant, 3)
  end

  describe "#index" do
    before do 
      get "/api/v1/merchants"
    end

    context "when successful" do
      it "GET all merchants" do
        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data].count).to eq(3)
        expect(parsed[:data]).to be_an(Array)
        expect(parsed[:data][0].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][0][:attributes][:name]).to eq(Merchant.first.name)
      end
    end

    # context "when unsuccessful" do
    #   it "returns error message" do
    #     expect(response).to have_http_status(404)
    #   end
    # end
  end

  describe "#show" do
    before do
      @merchant = Merchant.first
      get "/api/v1/merchants/#{@merchant.id}"
    end

    context "when successful" do
      it "GET one merchant" do
        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data][:id]).to eq(@merchant.id.to_s)
        expect(parsed[:data][:id]).to_not eq(Merchant.last.id.to_s)
        expect(parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][:attributes][:name]).to eq(@merchant.name)

        expect(parsed[:data][:attributes].count).to eq(1)
      end
    end
  end

  # describe "#new" do
  #   before do
  #     get "/api/v1/merchants/new"
  #   end

  #   context "when successful" do
  #     it "GET one merchant" do
  #       expect(response).to be_successful

  #       parsed = JSON.parse(response.body, symbolize_names: true)

  #       expect(parsed[:data][:id]).to eq(Merchant.first.id.to_s)
  #       expect(parsed[:data][:id]).to_not eq(Merchant.last.id.to_s)

  #       expect
  #     end
  #   end
  # end
end