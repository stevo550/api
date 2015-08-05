require 'rails_helper'

describe 'Orders API' do
  let(:default_params) { { format: :json } }

  describe 'GET index' do
    before(:each) do
      @order1 = create :order
      @order2 = create :order
      sign_in_as create :staff, :admin
      @orders = Order.all
    end

    it 'returns a collection of all of the orders w/ items', :show_in_doc do
      get '/api/v1/orders'
      expect(response.body).to eq(@orders.map { |o| OrderSerializer.new(o).as_json(include: [:order_items]) }.to_json)
    end

    it 'paginates the orders' do
      get '/api/v1/orders', page: 1, per_page: 1
      expect(json.length).to eq(1)
    end
  end

  describe 'GET show' do
    before(:each) do
      create :order
      sign_in_as create :staff, :admin
      @order = Order.first
    end

    it 'returns an order', :show_in_doc do
      get "/api/v1/orders/#{@order.id}"
      expect(response.body).to eq(OrderSerializer.new(@order).to_json(include: [:order_items]))
    end

    it 'returns an error when the order does not exist' do
      get "/api/v1/orders/#{@order.id + 999}"
      expect(response.status).to eq(404)
      expect(json).to eq('error' => 'Not found.')
    end
  end

  describe 'PUT update' do
    before(:each) do
      create :order
      sign_in_as create :staff, :admin
      @order = Order.first
    end

    it 'updates a order', :show_in_doc do
      put "/api/v1/orders/#{@order.id}", staff_id: Staff.all.first.id, options: ['test']
      expect(response.status).to eq(204)
    end

    it 'returns an error when the order does not exist' do
      put "/api/v1/orders/#{@order.id + 999}", staff_id: Staff.all.first.id, options: ['test']
      expect(response.status).to eq(404)
      expect(json).to eq('error' => 'Not found.')
    end
  end

  describe 'POST create' do
    before :each do
      sign_in_as create :staff, :admin
    end

    it 'creates an order', :show_in_doc do
      product = create(:product)
      project = create(:project)
      post '/api/v1/orders/', staff_id: Staff.all.first.id, order_items: [{ product_id: product.id, project_id: project.id }]
      expect(response.body).to eq(OrderSerializer.new(Order.first).to_json)
    end

    it 'does not create an order if the project is over budget', :show_in_doc do
      product = create(:product, setup_price: 100)
      project = create(:project, budget: 10)
      post '/api/v1/orders/', staff_id: Staff.all.first.id, order_items: [{ product_id: product.id, project_id: project.id }]
      expect(response.code).to eq('409')
    end
  end

  describe 'DELETE destroy' do
    before :each do
      @order = create :order
      sign_in_as create :staff, :admin
    end

    it 'removes the order', :show_in_doc do
      delete "/api/v1/orders/#{@order.id}"
      expect(response.status).to eq(204)
    end

    it 'returns an error when the order does not exist' do
      delete "/api/v1/orders/#{@order.id + 999}"
      expect(response.status).to eq(404)
      expect(json).to eq('error' => 'Not found.')
    end
  end

  context 'Items' do
    describe 'GET /orders/:id/items' do
      before :each do
        @order = create :order, :with_items
        sign_in_as create :staff, :admin
      end

      it 'returns a list of items' do
        get "/api/v1/orders/#{@order.id}/items"
        expect(json.length).to eq(2)
      end
    end
  end
end
