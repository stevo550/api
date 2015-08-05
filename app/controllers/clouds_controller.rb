class CloudsController < ApplicationController
  after_action :verify_authorized

  api :GET, '/clouds', 'Returns a collection of clouds'
  param :includes, Array, required: false, in: %w(chargebacks)
  param :page, :number, required: false
  param :per_page, :number, required: false

  def index
    respond_with_params clouds
  end

  api :GET, '/clouds/:id', 'Shows cloud with :id'
  param :id, :number, required: true
  param :includes, Array, required: false, in: %w(chargebacks)
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def show
    respond_with_params cloud
  end

  api :POST, '/clouds', 'Creates a cloud'
  param :name, String, required: false
  param :desciption, String, required: false
  param :extra, String, required: false
  error code: 422, desc: ParameterValidation::Messages.missing

  def create
    authorize Cloud
    respond_with Cloud.create permitted_attributes Cloud
  end

  api :PUT, '/cloud/:id', 'Updates cloud with :id'
  param :id, :number, required: true
  param :name, String, required: false
  param :desciption, String, required: false
  param :extra, String, required: false
  error code: 404, desc: MissingRecordDetection::Messages.not_found
  error code: 422, desc: ParameterValidation::Messages.missing

  def update
    respond_with cloud.update_attributes permitted_attributes cloud
  end

  api :DELETE, '/cloud/:id', 'Deletes cloud with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def destroy
    respond_with cloud.destroy
  end

  private

  def cloud
    @cloud = Cloud.find(params.require(:id)).tap { |c| authorize(c) }
  end

  def clouds
    @clouds ||= begin
      authorize(Cloud)
      query_with Cloud.all, :includes, :pagination
    end
  end
end
