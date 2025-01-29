class CartsController < ApplicationController
  # Define current_cart in begining of session
  before_action :current_cart, only: [:create, :show, :update, :remove_product]

  # POST /cart
  def create
    find_or_validate_product
    validate_quantity
    add_product_to_cart
    render json: serialize_cart(@cart), status: :created
  rescue ActiveRecord::RecordNotFound
    render_error('Produto não encontrado', :not_found)
  rescue ArgumentError => e
    render_error(e.message, :unprocessable_entity)
  end

  # GET /cart
  def show
    render json: serialize_cart(@cart)
  end

  # POST /cart/add_item
  def update
    find_or_validate_product
    validate_quantity
    add_product_to_cart
    render json: serialize_cart(@cart)
  rescue ActiveRecord::RecordNotFound
    render_error('Produto não encontrado', :not_found)
  rescue ArgumentError => e
    render_error(e.message, :unprocessable_entity)
  end

  # POST /cart/:product_id
  def remove_product
    product = Product.find(params[:product_id])
    @cart.remove_product(product)
    render json: serialize_cart(@cart)
  rescue ActiveRecord::RecordNotFound
    render_error('Produto não encontrado', :not_found)
  end

  private

  def serialize_cart(cart)
    {
      id: cart.id,
      products: cart.cart_items.map { |item| serialize_cart_item(item) },
      total_price: calculate_total_price(cart)
    }
  end

  def serialize_cart_item(item)
    {
      id: item.product.id,
      name: item.product.name,
      quantity: item.quantity,
      unit_price: item.product.price,
      total_price: item.quantity * item.product.price
    }
  end

  def calculate_total_price(cart)
    cart.cart_items.sum { |item| item.quantity * item.product.price }
  end

  def current_cart
    @cart ||= begin
      Cart.find_by(id: session[:cart_id]) || Cart.create!(total_price: 0)
    end
    session[:cart_id] = @cart.id
    @cart
  end

  def find_or_validate_product
    @product = Product.find(params[:product_id])
  end

  def validate_quantity
    @quantity = params[:quantity].to_i
    raise ArgumentError, 'A quantidade do produto deve ser maior que zero' unless @quantity.positive?
  end

  def add_product_to_cart
    @cart.add_product(@product, @quantity)
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end
end
