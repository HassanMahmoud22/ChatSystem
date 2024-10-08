class Api::V1::ChatsController < ApplicationController
  before_action :set_chat_service

  def create
    begin
      chat_number = @chat_service.create_chat
      render json: { message: "Chat created successfully", chat_number: chat_number }, status: :created
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: determine_status_code(e)
    end
  end

  def index
    begin
    @chats = @chat_service.application_chats
    render json: @chats
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end
  end

  private
  def determine_status_code(exception)
    case exception
    when ActiveRecord::RecordNotFound
      404 # Not Found
    else
      500 # Internal Server Error
    end
  end

  def set_chat_service
    if params[:application_token].blank?
      render json: { error: "Application token is required" }, status: :bad_request
    else
      @chat_service = ChatsService.new(params[:application_token])
    end
  end
end
