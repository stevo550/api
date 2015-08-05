class GroupsController < ApplicationController
  api :GET, '/groups', 'Returns a collection of groups'
  param :includes, Array, in: %w(staff)
  param :page, :number
  param :per_page, :number

  def index
    authorize Group
    respond_with_params groups
  end

  api :GET, '/groups/:id', 'Shows group with :id'
  param :id, :number, required: true
  param :includes, Array, in: %w(staff)
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def show
    authorize group
    respond_with_params group
  end

  api :POST, '/groups', 'Creates group'
  param :name, String, desc: 'Group Name', required: true
  param :description, String, desc: 'Group Description'
  param :staff_ids, Array
  error code: 422, desc: ParameterValidation::Messages.missing

  def create
    authorize Group
    respond_with_params Group.create permitted_attributes Group
  end

  api :PUT, '/groups/:id', 'Updates group with :id'
  param :id, :number, required: true
  param :name, String, desc: 'Group Name'
  param :description, String, desc: 'Group Description'
  param :staff_ids, Array
  error code: 404, desc: MissingRecordDetection::Messages.not_found
  error code: 422, desc: ParameterValidation::Messages.missing

  def update
    authorize group
    group.update! permitted_attributes group
    respond_with_params group
  end

  api :DELETE, '/groups/:id', 'Deletes group with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def destroy
    authorize group
    group.destroy
    respond_with_params group
  end

  private

  def group
    @_group ||= (query_with Group.where(id: params.require(:id)), :includes).first || fail(ActiveRecord::RecordNotFound)
  end

  def groups
    @_groups ||= query_with Group.all, :includes, :pagination
  end
end
