class ChatsDatastore

  def self.get_chat_id(application_token, chat_number)
    chat_data = ChatRedisRepository.get_chat(application_token, chat_number)
    if chat_data
      return chat_data["id"].to_i
    end
    chat = ChatDatabaseRepository.get_chat(application_token, chat_number)
    if chat
      ChatRedisRepository.set_chat(application_token, chat)
      return chat.id
    end
    Rails.logger.error("Chat not found for application_token: #{application_token}, chat_number: #{chat_number}")
    raise ActiveRecord::RecordNotFound, "Chat not found for application_token: #{application_token}, chat_number: #{chat_number}"
  end

  def self.create_chat_and_update_counts(application_token)
    chat_number = nil
    chat_count = nil
    LockRedisRepository.acquire_lock(application_token, chat_number,) do
      ApplicationRecord.transaction do
        validate_application_last_chat_number(application_token)
        application_id = ApplicationsDatastore.get_application_id_by_token(application_token)
        chat_number = increment_application_chat_number(application_token)
        ChatDatabaseRepository.create_chat(application_id, chat_number)
        chat_count = increment_application_chat_count(application_token)
        add_application_needing_sync(application_token)
        chat_number
      end
    end
  rescue StandardError => e
    handle_creation_failure(application_token, chat_number, chat_count, e)
  end

  def self.handle_creation_failure(application_token, chat_number, chat_count, error)
    decrement_application_chat_number(application_token) if chat_number
    decrement_application_chat_count(application_token) if chat_count
    raise error
  end

  def self.validate_application_last_chat_number(application_token)
    ApplicationsDatastore.validate_application_last_chat_number(application_token)
  end

  def self.increment_application_chat_number(application_token)
    ChatRedisRepository.increment_application_chat_number(application_token)
  end

  def self.increment_application_chat_count(application_token)
    ChatRedisRepository.increment_application_chat_count(application_token)
  end

  def self.decrement_application_chat_number(application_token)
    ChatRedisRepository.decrement_application_chat_number(application_token)
  end

  def self.decrement_application_chat_count(application_token)
    ChatRedisRepository.decrement_application_chat_count(application_token)
  end

  def self.add_application_needing_sync(application_token)
    ChatRedisRepository.add_application_needing_sync(application_token)
  end

  def self.get_application_chats(application_token)
    application_id = ApplicationsDatastore.get_application_id_by_token(application_token)
    chats = ChatDatabaseRepository.get_application_chats(application_id).map do |chat|
      {
        chat_number: chat.chat_number,
        messages_count: MessageRedisRepository.get_chat_messages_count(application_token, chat.chat_number) || chat.messages_count
      }
    end
    chats
  end
end
