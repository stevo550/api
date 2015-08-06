class UserSettingOptionsController < ApplicationController
  after_action :verify_authorized

  api :GET, '/user_setting_options', 'Returns a set of default staff options.'
  param :page, :number, required: false
  param :per_page, :number, required: false

  def index
    respond_with user_setting_options
  end

  api :GET, '/user_setting_options/:id', 'Shows user setting option with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def show
    respond_with user_setting_option
  end

  api :POST, '/user_setting_options', 'Create new setting that all users will have.'
  param :label, String, required: true, desc: 'The label of the setting. Varchar(255)'
  param :field_type, String, required: true, desc: 'The field type (text, textarea, radio, checkbox). Varchar(100)'
  param :help_text, String, required: true, desc: 'Inline help text to display. Varchar(255)'
  param :options, String, required: true, desc: 'JSON for options for field_type that needs them (like radio, checkbox, etc). Text BLOB.'
  param :required, String, required: true, desc: 'Whether option is mandatory. Boolean'

  def create
    authorize UserSettingOption
    user_setting_option = UserSettingOption.new permitted_attributes UserSettingOption
    if id_for_user_setting_option_label.nil?
      if user_setting_option.save
        respond_with user_setting_option
      else
        respond_with user_setting_option.errors, status: :unprocessable_entity
      end
    else # ON DUPLICATE KEY UPDATE
      params[:id] = id_for_user_setting_option_label
      user_setting_option
      update
    end
  end

  api :PUT, '/user_setting_options/:id', 'Updates user setting option with :id'
  param :id, :number, required: true
  param :field_type, String, required: false, desc: 'The field type (text, textarea, radio, checkbox). Varchar(100)'
  param :help_text, String, required: false, desc: 'Inline help text to display. Varchar(255)'
  param :options, String, required: false, desc: 'JSON for options for field_type that needs them (like radio, checkbox, etc). Text BLOB.'
  param :required, String, required: false, desc: 'Whether option is mandatory. Boolean'
  error code: 404, desc: MissingRecordDetection::Messages.not_found
  error code: 422, desc: ParameterValidation::Messages.missing

  def update
    respond_with user_setting_option.update_attributes(permitted_attributes(user_setting_option)) ||
                   user_setting_option.errors, status: :unprocessable_entity
  end

  api :GET, '/user_setting_options/new', 'Get new setting JSON'

  def new
    authorize UserSettingOption
    respond_with UserSettingOption.new
  end

  api :GET, '/user_setting_options/:id/edit', 'Get edit JSON for user setting option with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def edit
    respond_with user_setting_option
  end

  api :DELETE, '/user_setting_options/:id', 'Deletes user setting option with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def destroy
    respond_with user_setting_option.destroy || user_setting_option.errors, status: :unprocessable_entity
  end

  private

  def permitted_attributes(record)
    if record.new_record?
      params.require(:label)
      params.require(:field_type)
      params.require(:help_text)
      params.require(:options)
      params.require(:required)
    end
    params.permit(*policy(record).permitted_attributes)
  end

  def user_setting_options
    @user_setting_options ||= begin
      authorize UserSettingOption
      query_with UserSettingOption.all.order('id ASC'), :includes, :pagination
    end
  end

  def user_setting_option
    @user_setting_option = UserSettingOption.find(params.require(:id)).tap { |o| authorize(o) }
  end

  def id_for_user_setting_option_label
    user_setting_option_label = UserSettingOption.where(label: params[:label]).first
    @id_for_user_setting_option_label = (user_setting_option_label.nil? || user_setting_option_label.id.nil?) ? nil : user_setting_option_label.id
  end
end
