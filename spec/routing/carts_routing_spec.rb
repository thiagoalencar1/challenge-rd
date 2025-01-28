require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe 'routes' do
    it 'routes to #create' do
      expect(post: '/cart').to route_to('carts#create')
    end

    it 'routes to #show' do
      expect(get: '/cart').to route_to('carts#show')
    end

    it 'routes to #update via POST' do
      expect(post: '/cart/add_item').to route_to('carts#update')
    end

    it 'routes to #remove_product via POST' do
      expect(post: '/cart/1').to route_to(
        controller: 'carts',
        action: 'remove_product',
        product_id: '1'
      )
    end
  end
end
