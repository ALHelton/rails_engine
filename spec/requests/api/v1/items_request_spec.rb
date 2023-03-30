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
    before do
      @id = create(:merchant).id
      @item_params = ({
                    name: "Shiny Itemy Item",
                    description: "It does a lot of things real good",
                    unit_price: 40.00,
                    merchant_id: @id
                    })
      @headers = {"CONTENT_TYPE" => "application/json"}
    end

    context "when successful" do
      it "creates a new item" do
        post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_params)
        created_item = Item.last
        parsed = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(201)
        expect(parsed[:data][:type]).to eq('item')
        expect(parsed[:data][:attributes][:name]).to eq(created_item.name)
        expect(parsed[:data][:attributes][:description]).to eq(created_item.description)
        expect(parsed[:data][:attributes][:unit_price]).to eq(created_item.unit_price)
        expect(parsed[:data][:attributes][:merchant_id]).to eq(created_item.merchant_id)
        expect(parsed[:data][:attributes][:unit_price]).to be_a(Float)
        expect(parsed[:data][:attributes].size).to eq(4)
      end
    end

    context "when unsuccessful" do
      describe "returns a 400 status" do
        it "nil name" do
          @item_params[:name] = nil
          post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_params)
          parsed = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Name can't be blank")
        end

        it "nil description" do
          @item_params[:description] = nil
          post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_params)
          parsed = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Description can't be blank")
        end

        it "nil / invalid unit_price" do
          @item_params[:unit_price] = nil
          post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_params)
          parsed = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Unit price can't be blank, Unit price is not a number")


          @item_params[:unit_price] = "abc"
          post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_params)
          parsed = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Unit price is not a number")

        end

        it "nil / invalid merchant_id" do
          @item_params[:merchant_id] = nil
          post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_params)
          parsed = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Merchant must exist, Merchant can't be blank")

          @item_params[:merchant_id] = "abc"
          post "/api/v1/items", headers: @headers, params: JSON.generate(item: @item_params)
          parsed = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Merchant must exist")
        end
      end
    end
  end

  describe "#destroy" do
    before do
      merchant = create(:merchant)
      customer = create(:customer)
      @item1 = create(:item, merchant_id: merchant.id)
      item2 = create(:item, merchant_id: merchant.id)
      item3 = create(:item, merchant_id: merchant.id)
      @invoice = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
      @invoice2 = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
      
      ii1 = create(:invoice_item, invoice_id: @invoice.id, item_id: @item1.id)
      ii2 = create(:invoice_item, invoice_id: @invoice2.id, item_id: item2.id)
      ii3 = create(:invoice_item, invoice_id: @invoice2.id, item_id: item3.id)
      
      t1 = create(:transaction, invoice_id: @invoice.id)
      t2 = create(:transaction, invoice_id: @invoice.id)
      t3 = create(:transaction, invoice_id: @invoice2.id)
      
    end
    
    context "when successful" do
      it "deletes an item" do
        expect(Item.count).to eq(8)
        delete "/api/v1/items/#{@item1.id}"
        expect(response).to have_http_status(204)
        expect(Item.count).to eq(7)
        expect{ Item.find(@item1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "deletes invoice associated with item (if only one on invoice)" do
        expect(Invoice.count).to eq(2)
        expect(InvoiceItem.count).to eq(3)

        delete "/api/v1/items/#{@item1.id}"
        expect(Invoice.count).to eq(1)
        expect(InvoiceItem.count).to eq(2)
      end
    end

    context "when unsuccessful" do
      it "should return 404 error" do
        expect(Item.count).to eq(8)
        delete "/api/v1/items/abc"
        expect(response).to have_http_status(404)
        expect(Item.count).to eq(8)
        parsed = JSON.parse(response.body, symbolize_names: true)
        expect(parsed[:error]).to eq("Couldn't find Item with 'id'=abc")
      end
    end
  end

  describe "#update" do
    before do
      @id = create(:item).id
      @previous_name = Item.find_by(id: @id).name
      @item_params = { name: "Some Thing" }
      @headers = {"CONTENT_TYPE" => "application/json"}
    end

    context "when successful" do
      it "updates an existing item" do
        patch "/api/v1/items/#{@id}", headers: @headers, params: JSON.generate({item: @item_params})
        parsed = JSON.parse(response.body, symbolize_names: true)
        updated_item = Item.find_by(id: @id)
        
        expect(response).to be_successful
        expect(parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(parsed[:data][:type]).to eq('item')
        expect(parsed[:data][:attributes][:name]).to eq(updated_item.name)
        expect(parsed[:data][:attributes][:name]).to_not eq(@previous_name)
        expect(parsed[:data][:attributes][:description]).to eq(updated_item.description)
        expect(parsed[:data][:attributes][:unit_price]).to eq(updated_item.unit_price)
        expect(parsed[:data][:attributes][:unit_price]).to be_a(Float)
        expect(parsed[:data][:attributes][:merchant_id]).to eq(updated_item.merchant_id)
        expect(parsed[:data][:attributes].size).to eq(4)
      end
    end

    context "when unsuccessful" do      
      describe "returns a 404 error" do
        before do
          @nil_item_params = { name: nil }
          @nil_description_params = { description: nil }
          @nil_unit_price_params = { unit_price: nil }
          @abc_unit_price_params = { unit_price: "not the correct datatype" }
          @nil_merchant_id_params = { merchant_id: nil }
          @abc_merchant_id_params = { merchant_id: "abc" }
        end
        
        it "nil name" do
          patch "/api/v1/items/#{@id}", headers: @headers, params: JSON.generate({item: @nil_item_params})
          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Name can't be blank")
        end

        it "nil description" do
          patch "/api/v1/items/#{@id}", headers: @headers, params: JSON.generate({item: @nil_description_params})
          parsed = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Description can't be blank")
        end

        it "nil / invalid unit_price" do
          patch "/api/v1/items/#{@id}", headers: @headers, params: JSON.generate({item: @nil_unit_price_params})
          parsed = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Unit price can't be blank, Unit price is not a number")

          patch "/api/v1/items/#{@id}", headers: @headers, params: JSON.generate({item: @abc_unit_price_params})
          parsed = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Unit price is not a number")

        end

        it "nil / invalid merchant_id" do
          patch "/api/v1/items/#{@id}", headers: @headers, params: JSON.generate({item: @nil_merchant_id_params})
          parsed = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Merchant must exist, Merchant can't be blank")

          patch "/api/v1/items/#{@id}", headers: @headers, params: JSON.generate({item: @abc_merchant_id_params})
          parsed = JSON.parse(response.body, symbolize_names: true)
          expect(response).to have_http_status(400)
          expect(parsed[:error]).to eq("Validation failed: Merchant must exist")
        end
      end
    end
  end

  describe "Item Merchant Data" do
    context "when successful" do
      before do
        @merchant = create(:merchant)
        create_list(:item, 5, merchant_id: @merchant.id)
        @item = @merchant.items.first
        get "/api/v1/items/#{@item.id}/merchant"
        @parsed = JSON.parse(response.body, symbolize_names: true)
      end

      it "Gets the merchant data for a given item ID" do
        expect(response).to be_successful
        expect(@parsed[:data][:type]).to eq('merchant')
        expect(@parsed[:data].keys).to eq([:id, :type, :attributes])
        expect(@parsed[:data][:attributes][:name]).to eq(@merchant.name)
      end
    end
  end
end