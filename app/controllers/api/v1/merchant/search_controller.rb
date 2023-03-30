class Api::V1::Merchant::SearchController < ApplicationController
  def search
    merchant = Merchant.find_by_name(params[:name])
    if merchant == nil
      render json: { data: {}}
    else
      render json: MerchantSerializer.new(merchant)
    end
  end
end