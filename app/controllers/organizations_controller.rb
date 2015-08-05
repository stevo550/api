class OrganizationsController < ApplicationController
  api :GET, '/organizations', 'Returns a collection of organizations'
  param :page, :number, required: false
  param :per_page, :number, required: false

  def index
    respond_with_params organizations
  end

  api :GET, '/organizations/:id', 'Shows organization with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def show
    respond_with_params organization
  end

  api :POST, '/organizations', 'Creates organization'
  param :name, String, desc: 'Name'
  param :image, String, desc: 'Image URL'
  param :description, String, desc: 'Description of organization'
  error code: 422, desc: MissingRecordDetection::Messages.not_found

  def create
    authorize Organization
    respond_with Organization.new permitted_attributes Organization
  end

  api :PUT, '/organizations/:id', 'Updates organization with :id'
  param :id, :number, required: true
  param :name, String, desc: 'Name'
  param :image, String, desc: 'Image URL'
  param :description, String, desc: 'Description of organization'
  error code: 404, desc: MissingRecordDetection::Messages.not_found
  error code: 422, desc: ParameterValidation::Messages.missing

  def update
    respond_with organization.update_attributes permitted_attributes organization
  end

  api :DELETE, '/organizations/:id', 'Deletes organization with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def destroy
    respond_with organization.destroy
  end

  private

  def organization
    @organization = Organization.find(params.require(:id)).tap { |o| authorize(o) }
  end

  def organizations
    @organizations ||= begin
      authorize(Organization)
      query_with Organization.all, :includes, :pagination
    end
  end
end
