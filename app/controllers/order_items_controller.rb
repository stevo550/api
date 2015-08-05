class OrderItemsController < ApplicationController
  after_action :verify_authorized

  api :GET, '/order_items/:id', 'Shows order item with :id'
  param :includes, Array, required: false, in: %w(alerts product)
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def show
    respond_with_params order_item
  end

  api :PUT, '/order_items/:id', 'Updates order item with :id'
  param :id, :number, required: true
  param :hourly_price, :number, required: false
  param :monthly_price, :number, required: false
  param :setup_price, :number, required: false
  error code: 404, desc: MissingRecordDetection::Messages.not_found
  error code: 422, desc: ParameterValidation::Messages.missing

  def update
    respond_with order_item.update_attributes permitted_attributes order_item
  end

  api :DELETE, '/order_items/:id', 'Deletes order item with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def destroy
    respond_with order_item.destroy
  end

  api :PUT, '/order_items/:id/retire_service'
  param :id, :number, required: true

  def retire_service
    order_item.provisioner.delay(queue: 'retire_request').retire
    render nothing: true, status: :ok
  end

  private

  def order_item
    @order_item = OrderItem.find(params.require(:id)).tap { |i| authorize(i) }
  end
end
