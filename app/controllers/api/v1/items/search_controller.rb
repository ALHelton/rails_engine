class Api::V1::Items::SearchController < ApplicationController
  def search
    if params[:name] && params[:min_price] && params[:max_price]
      render json: { errors: "Can't search by name and price" }, status: 400
 
    elsif params[:name] && !params[:min_price] && !params[:max_price]
      items_by_name = Item.find_by_name(params[:name])
      render json: ItemSerializer.new(items_by_name)
 
    elsif params[:min_price] && params[:max_price] && !params[:name]
      if params[:min_price].to_i >= 0 && params[:max_price].to_i >= 0
        items_between_prices = Item.find_between_prices(params[:min_price], params[:max_price])
        render json: ItemSerializer.new(items_between_prices)
      else
        render json: { errors: "Price must be greater than 0" }, status: 400
      end
 
    elsif params[:min_price] && !params[:name] && !params[:max_price]
      if params[:min_price].to_i >= 0 
        items_over_min_price = Item.find_at_or_above_price(params[:min_price])
        render json: ItemSerializer.new(items_over_min_price)
      else
        render json: { errors: "Price must be greater than 0" }, status: 400
      end
     
    elsif params[:max_price] && !params[:name] && !params[:min_price]
      if params[:max_price].to_i >= 0
        items_under_max_price = Item.find_at_or_below_price(params[:max_price])
        render json: ItemSerializer.new(items_under_max_price)
      else
        render json: { errors: "Price must be greater than 0" }, status: 400
      end

    else
      render json: { errors: "Missing Parameters" }, status: 400
    end
  end

end