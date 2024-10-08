class MessageDatabaseRepository

  def self.create_message(chat_id, message_number, message_body)
    Message.create!(chat_id: chat_id, message_number: message_number, body: message_body)
  end

  def self.get_messages_by_chat_id(chat_id)
    Message.where(chat_id: chat_id).order(:message_number)
  end

  def self.search(chat_id, query)
    Message.where("body LIKE ? AND chat_id = ?", "%#{query}%", chat_id)
  end

  def self.max_message_number(chat)
    chat.messages.maximum(:message_number) || 0
  end
end
