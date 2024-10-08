class ChatDatabaseRepository

  def self.create_chat(application_id, chat_number)
    Chat.create!(application_id: application_id, chat_number: chat_number)
  end

  def self.get_chat(application_token, chat_number)
    application = Application.find_by(token: application_token)
    raise ActiveRecord::RecordNotFound, "Application not found" unless application
    chat = Chat.find_by(application_id: application.id, chat_number: chat_number)
    raise ActiveRecord::RecordNotFound, "Chat not found" unless chat
    chat
  end

  def self.get_application_chats(application_id)
    Chat.where(application_id: application_id)
  end
end
