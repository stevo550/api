class OrdersController < ApplicationController
  after_action :verify_authorized

  api :GET, '/orders', 'Returns a collection of orders'
  param :page, :number, required: false
  param :per_page, :number, required: false
  param :includes, Array, required: false, in: %w(order_items staff)

  def index
    respond_with_params orders
  end

  api :GET, '/orders/:id', 'Shows order with :id'
  param :includes, Array, required: false, in: %w(order_items staff)
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def show
    respond_with_params order
  end

  api :POST, '/orders', 'Creates order'
  param :order_items, Array, desc: 'Order Items', required: false do
    param :project_id, :number, desc: 'Id for Project', required: true
    param :product_id, :number, desc: 'Id for Product', required: true
    param :cloud_id, :number, desc: 'Id for cloud', required: false
  end
  param :staff_id, :number, required: true
  param :total, :decimal, required: false
  param :options, Array, desc: 'Options'
  param :bundle_id, :number, required: false
  error code: 422, desc: ParameterValidation::Messages.missing

  def create
    authorize Order
    ap filter_params Order
    order = Order.new filter_params Order

    order.order_items.each do |oi|
      oi.hourly_price = oi.product.hourly_price
      oi.monthly_price = oi.product.monthly_price
      oi.setup_price = oi.product.setup_price
    end

    if order.exceeds_budget?
      render json: { error: 'The budget for one or more of these projects has been, or will be exceeded.' }, status: 409
    else
      order.save
      respond_with order
    end
  end

  api :PUT, '/orders/:id', 'Updates order with :id'
  param :id, :number, required: true
  param :order_items, Array, desc: 'Order Items', required: false do
    param :id, :number, desc: 'Id for Project', required: true
    param :project_id, :number, desc: 'Id for Project', required: true
    param :product_id, :number, desc: 'Id for Product', required: true
    param :cloud_id, :number, desc: 'Id for cloud', required: false
  end
  param :staff_id, :number, required: true
  param :options, Array, desc: 'Options'
  param :total, :decimal, required: false
  param :bundle_id, :number, required: false
  error code: 422, desc: ParameterValidation::Messages.missing
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def update
    respond_with order.update filter_params order
  end

  api :DELETE, '/orders/:id', 'Deletes order with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def destroy
    respond_with order.destroy
  end

  api :GET, '/orders/:id/items', 'Gets a list of order items for the order'
  param :id, :number, required: true
  param :page, :number, required: false
  param :per_page, :number, required: false
  param :includes, Array, required: false, in: %w(project product latest_alert)

  def items
    authorize order
    respond_with_params order_items
  end

  protected

  def filter_params(record)
    permitted_attributes(record).store(:order_items_attributes, params.delete(:order_items))
  end

  def order
    @order = Order.find(params.require(:id)).tap { |o| authorize(o) }
  end

  def orders
    @orders ||= begin
      authorize(Order)
      query_with Order.all, :includes, :pagination
    end
  end

  def order_items
    @order = Order.find(params.require(:id)).tap { |o| authorize(o) }
    @order_items = query_with OrderItem.where(order_id: @order.id), :includes, :pagination
  end
end
