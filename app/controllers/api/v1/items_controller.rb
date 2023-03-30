class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    item = Item.new(item_params)
    item.save!
    render json: ItemSerializer.new(item), status: 201
  end

  def destroy
    item = Item.find(params[:id])
    item.single_item_invoices.destroy_all
    item.destroy
  end

  def update
    item = Item.update!(params[:id], item_params)
    render json: ItemSerializer.new(item)
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end