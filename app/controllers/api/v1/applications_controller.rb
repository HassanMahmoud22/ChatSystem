class Api::V1::ApplicationsController < ApplicationController
  before_action :set_application_service

  def create
    application = @application_service.create_application(application_name)
    render json: { token: application.token }, status: :created
  rescue ActiveRecord::RecordInvalid
    render json: { error: "Invalid Application Name" }, status: :bad_request
  end

  def show
    application = @application_service.get_application(params[:token])
    render json: { application: application }, status: :ok
  rescue ActiveRecord::RecordInvalid
    render json: { error: "The Application Not Found" }, status: :bad_request
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def update
    application = @application_service.update_application(params[:token], application_name[:name])
    render json: { message: "Application updated successfully", application: application }, status: :ok
  rescue ActiveRecord::RecordInvalid
    render json: { error: "Invalid Application Name" }, status: :bad_request
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  private

  def application_name
    params.require(:application).permit(:name)
  end

  def set_application_service
    @application_service = ApplicationsService.new
  end
end

