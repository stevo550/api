class ProjectsController < ApplicationController
  PROJECT_INCLUDES = %w(latest_alerts alerts approvals approvers memberships groups project_answers project_detail services staff)
  PROJECT_METHODS = %w(account_number cpu domain hdd icon monthly_spend order_history problem_count ram resources resources_unit state state_ok status url users latest_service_alerts)
  before_action :pre_hook
  after_action :verify_authorized
  after_action :post_hook

  def self.document_project_params(required: false)
    param :approved, String
    param :budget, :decimal, precision: 12, scale: 2, required: required
    param :cc, String
    param :description, String
    param :end_date, String
    param :img, String
    param :name, String, required: required
    param :project_answers, Array, desc: 'Project answers' do
      param :project_question_id, :number, desc: 'Id for valid project question', required: true
    end
  end

  api :GET, '/projects', 'Returns a collection of projects'
  param :includes, Array, in: PROJECT_INCLUDES
  param :methods, Array, in: PROJECT_METHODS
  param :page, :number
  param :per_page, :number

  def index
    authorize_and_normalize(Project.new)
    projects = query_with policy_scope(Project).main_inclusions, :includes, :pagination
    respond_with_params projects
  end

  api :GET, '/projects/:id', 'Shows project with :id'
  param :id, :number, required: true
  param :includes, Array, in: PROJECT_INCLUDES
  param :methods, Array, in: PROJECT_METHODS
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def show
    authorize_and_normalize(project)
    build_empty_answers_to_questions(project) if project.project_answers.empty?
    respond_with_params project
  end

  api :POST, '/projects', 'Creates projects'
  document_project_params(required: true)
  param :start_date, String
  error code: 422, desc: ParameterValidation::Messages.missing

  def create
    authorize Project
    group_ids = current_user.admin? ? params[:group_ids] : params.require(:group_ids)
    project = Project.create permitted_attributes(Project).merge(group_ids: group_ids)
    respond_with_params project
  end

  api :PUT, '/projects/:id', 'Updates project with :id'
  param :id, :number, required: true
  param :includes, Array, in: PROJECT_INCLUDES
  document_project_params
  error code: 404, desc: MissingRecordDetection::Messages.not_found
  error code: 422, desc: ParameterValidation::Messages.missing

  def update
    authorize project
    group_ids = current_user.admin? ? params[:group_ids] : params.require(:group_ids)
    project.update permitted_attributes(project).merge(group_ids: group_ids)
    respond_with_params project
  end

  api :DELETE, '/projects/:id', 'Deletes project with :id'
  param :id, :number, required: true
  error code: 404, desc: MissingRecordDetection::Messages.not_found

  def destroy
    authorize project
    project.destroy
    respond_with project
  end

  private

  def project_params
    @_project_params ||= params.permit(:name, :description, :cc, :budget, :start_date, :end_date, :approved, :img, project_answers: [:project_question_id, :answer, :id]).tap do |project|
      if params[:project_answers]
        project[:project_answers_attributes] = project.delete(:project_answers)
      end
      if !current_user.admin? && !project[:id].nil?
        project.delete(:budget)
      end
    end
  end

  def authorize_and_normalize(project)
    authorize project
    if render_params.fetch(:include, {})[:project_answers]
      render_params[:include][:project_answers][:include] = :project_question
    end
  end

  def build_empty_answers_to_questions(project)
    ProjectQuestion.where.not(id: project.project_answer_ids).each do |pq|
      project.project_answers.build(project_question: pq)
    end
  end

  def project
    @_project ||= Project.find(params[:id])
  end
end
