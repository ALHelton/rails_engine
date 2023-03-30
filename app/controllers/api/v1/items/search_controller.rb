class Api::V1::Items::SearchController < ApplicationController
  def search
    items_by_name = Item.find_by_name(params[:name])
    if items_by_name == nil
      render json: { data: [] }
    else
      render json: ItemSerializer.new(items_by_name)
    end

    # items_by_price = Item.find_by_price(params[:unit_price])
    # items_over_min_price = Item.find_above_price(params[:unit_price])
    # items_over_max_price = Item.find_below_price(params[:unit_price])
    # items_between_price = Item.find_between_price(params[:unit_price])
  end
end