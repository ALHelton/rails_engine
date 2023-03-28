require "rails_helper"

describe "Merchants API" do
  before do
    create_list(:merchant, 3)
  end

  describe "#index" do
    before do 
      get '/api/v1/merchants'
    end

    context "when successful" do
      it "Get all merchants" do
        expect(response).to be_successful

        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(parsed[:data].count).to eq(3)
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
end