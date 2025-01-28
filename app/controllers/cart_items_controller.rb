class CartItemsController < ApplicationController
  before_action :set_cart
  before_action :set_product, only: [:create]

  def create
    @cart_item = @cart.cart_items.build(cart_item_params)

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

  private

  def set_cart
    @cart = Cart.find(params[:cart_id])
  end

  def set_product
    @product = Product.find(params[:product_id])
  end

  def cart_item_params
    { product: @product, quantity: params.require(:quantity) }
  end
end