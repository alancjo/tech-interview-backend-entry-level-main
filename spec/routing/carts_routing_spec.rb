require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe 'routes' do
    it 'routes to #show' do
      expect(get: '/cart').to route_to('carts#show')
    end

    it 'routes to #create via POST' do
      expect(post: '/cart').to route_to('carts#create')
    end

    it 'routes to #update_item via PATCH' do
      expect(patch: '/cart/add_item').to route_to('carts#update_item')
    end

    it 'routes to #remove_item via DELETE' do
      expect(delete: '/cart/1').to route_to(
        controller: 'carts',
        action: 'remove_item',
        product_id: '1'
      )
    end

    it 'does not route to #index' do
      expect(get: '/carts').not_to be_routable
    end

    it 'does not route to #edit' do
      expect(get: '/cart/edit').not_to be_routable
    end

    it 'does not route to #update' do
      expect(put: '/cart').not_to be_routable
      expect(patch: '/cart').not_to be_routable
    end

    it 'does not route to #destroy' do
      expect(delete: '/cart').not_to be_routable
    end
  end
end
