require "rails_helper"

describe "Merchants Search API", type: :request do
  before do
    @merch5 = FactoryBot.create(:merchant, name: "Art Shop")
    
    @merch1 = FactoryBot.create(:merchant, name: "Artist Shop")
    @merch2 = FactoryBot.create(:merchant, name: "Practical Arts")
    @merch3 = FactoryBot.create(:merchant, name: "Jerry's Artarama")
    @merch4 = FactoryBot.create(:merchant, name: "Walmart")
    @merch6 = FactoryBot.create(:merchant, name: "Dick Blick")
  end

  context "when successful" do
    it "finds a merchant that matches a case-insensitive search" do
      get "/api/v1/merchants/find?name=Art"
      parsed = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful
      expect(parsed[:data].keys).to eq([:id, :type, :attributes])
      expect(parsed[:data][:id]).to eq(@merch5.id.to_s)
      expect(parsed[:data][:type]).to eq('merchant')
      expect(parsed[:data][:attributes][:name]).to eq(@merch5.name)
      expect(parsed[:data][:attributes].size).to eq(1)
    end
  end

  context "when unsuccessful" do
    it "returns a 200 error if no match found" do
      get "/api/v1/merchants/find?name=xxx"
      parsed = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(parsed).to be_a(Hash)
      expect(parsed.keys).to eq([:data])
      expect(parsed[:data]).to eq({})
    end
  end
end