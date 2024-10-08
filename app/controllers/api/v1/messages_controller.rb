class Api::V1::MessagesController < ApplicationController
  before_action :set_messages_service

  def create
    message_number = @messages_service.create(params[:application_token], params[:chat_chat_number], message_params[:body])
    render json: { message: "Message created successfully", message_number: message_number }, status: :created
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :bad_request
  end

  def index
    begin
      @messages = @messages_service.get_chat_messages(params[:application_token], params[:chat_chat_number])
      render json: @messages
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end
  end

  def search
    begin
      messages = @messages_service.search(params[:application_token], params[:chat_chat_number], params[:query])
      if messages.any?
        render json: messages
      else
        render json: { message: "No messages found" }, status: :not_found
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end

  def set_messages_service
    if params[:application_token].blank? || params[:chat_chat_number].blank?
      render json: { error: "Application token is required" }, status: :bad_request
    else
      @messages_service = MessagesService.new
    end
  end
end
