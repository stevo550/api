class MotdsController < ApplicationController
  skip_before_action :require_user, only: [:show]
  after_action :verify_authorized, except: [:show]
  after_action :post_hook
  before_action :pre_hook

  def self.error_codes
    error code: 404, desc: MissingRecordDetection::Messages.not_found
    error code: 422, desc: ParameterValidation::Messages.missing
  end

  def self.document_params
    param :message, String, desc: 'Content of message of the day template', required: true
    error_codes
  end

  api :GET, '/motd', 'Returns message of the day.'
  error_codes

  def show
    respond_with_params Motd.first
  end

  api :POST, '/motd', 'Create new message of the day.'
  document_params

  def create
    motd_create_or_update
  end

  api :PUT, '/motd', 'Updates existing message of the day.'
  document_params

  def update
    motd_create_or_update
  end

  api :DELETE, '/motd', 'Clears the message of the day'
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def destroy
    respond_with_params motd.destroy
  end

  private

  def motd_create_or_update
    motd.staff_id = current_user.id
    motd.update permitted_attributes motd
    respond_with_params motd
  end

  def motd_params
    params.permit(:message)
  end

  def motd
    @_motd ||= Motd.first_or_initialize.tap { |m| authorize(m) }
  end
end
