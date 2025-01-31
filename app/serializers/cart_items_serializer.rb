class CartItemsSerializer < ActiveModel::Serializer
  attributes :id, :name, :quantity, :unit_price, :total_price

  def id
    object.product.id
  end

  def name
    object.product.name
  end

  def unit_price
    object.product.price
  end

  def total_price
    object.quantity * object.product.price
  end
end
