class CartItemsController < ApplicationController
  def create
    @cart = Cart.find(params[:cart_id])
    @product = Product.find(params[:product_id])
    @cart_item = @cart.cart_items.build(product: @product, quantity: params[:quantity])

    if @cart_item.save
      render json: @cart_item, status: :created
    else
      render json: @cart_item.errors, status: :unprocessable_entity
    end
  end

  def index
    @cart = Cart.find(params[:cart_id])
    @cart_items = @cart.cart_items.includes(:product)
    render json: @cart_items, include: :product
  end
end