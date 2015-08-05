class ChargebacksController < ApplicationController
  after_action :verify_authorized

  api :GET, '/chargebacks', 'Returns a collection of chargebacks'
  param :includes, Array, required: false, in: %w(cloud product)
  param :page, :number, required: false
  param :per_page, :number, required: false

  def index
    respond_with_params chargebacks
  end

  api :GET, '/chargebacks/:id', 'Shows chargeback with :id'
  param :id, :number, required: true
  param :includes, Array, required: false, in: %w(cloud product)
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def show
    respond_with_params chargeback
  end

  api :POST, '/chargebacks', 'Creates a chargeback'
  param :product_id, :number, required: false
  param :cloud_id, :number, required: false
  param :hourly_price, :number, required: false
  error code: 422, desc: ParameterValidation::Messages.missing

  def create
    authorize Chargeback
    respond_with Chargeback.create permitted_attributes Chargeback
  end

  api :PUT, '/chargeback/:id', 'Updates chargeback with :id'
  param :id, :number, required: true
  param :product_id, :number, required: false
  param :cloud_id, :number, required: false
  param :hourly_price, :number, required: false
  error code: 404, desc: MissingRecordDetection::Messages.not_found
  error code: 422, desc: ParameterValidation::Messages.missing

  def update
    respond_with chargeback.update_attributes permitted_attributes chargeback
  end

  api :DELETE, '/chargeback/:id', 'Deletes chargeback with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def destroy
    respond_with chargeback.destroy
  end

  private

  def chargeback
    @chargeback = Chargeback.find(params.require(:id)).tap { |c| authorize(c) }
  end

  def chargebacks
    @chargebacks ||= begin
      authorize(Chargeback)
      query_with Chargeback.all, :includes, :pagination
    end
  end
end
