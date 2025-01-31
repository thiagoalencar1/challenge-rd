class CartsController < ApplicationController
  # Define current_cart in begining of session
  before_action :current_cart, only: [:create, :show, :update, :remove_product]

  # POST /cart
  def create
    find_or_validate_product
    validate_quantity
    add_product_to_cart
    render json: @cart, serializer: CartSerializer, status: :created
  rescue ActiveRecord::RecordNotFound
    render_error('Produto não encontrado', :not_found)
  rescue ArgumentError => e
    render_error(e.message, :unprocessable_entity)
  end

  # GET /cart
  def show
    render json: @cart, serializer: CartSerializer
  end

  # POST /cart/add_item
  def update
    find_or_validate_product
    validate_quantity
    add_product_to_cart
    render json: @cart, serializer: CartSerializer
  rescue ActiveRecord::RecordNotFound
    render_error('Produto não encontrado', :not_found)
  rescue ArgumentError => e
    render_error(e.message, :unprocessable_entity)
  end

  # POST /cart/:product_id
  def remove_product
    product = Product.find(params[:product_id])
    @cart.remove_product(product)
    render json: @cart, serializer: CartSerializer
  rescue ActiveRecord::RecordNotFound
    render_error('Produto não encontrado', :not_found)
  end

  private

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
