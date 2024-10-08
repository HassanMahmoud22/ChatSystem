class MessagesDatastore

  def self.get_chat_messages(application_token, chat_number)
    chat_id = ChatsDatastore.get_chat_id(application_token, chat_number)
    MessageDatabaseRepository.get_messages_by_chat_id(chat_id)
  end

  def self.create_message_and_update_counts(application_token, chat_number, message_body)
    message_number = nil
    message_count = nil
    LockRedisRepository.acquire_lock(application_token, chat_number,) do
      ApplicationRecord.transaction do
        validate_chat_last_message_number(application_token, chat_number)
        chat_id = ChatsDatastore.get_chat_id(application_token, chat_number)
        message_number = increment_chat_message_number(application_token, chat_number)
        message = MessageDatabaseRepository.create_message(chat_id, message_number, message_body)
        message_count = increment_chat_messages_count(application_token, chat_number)
        ElasticSearchService.index_message(message)
        add_chat_needing_sync(application_token, chat_number)
        message_number
      end
    end
  rescue StandardError => e
    handle_creation_failure(application_token, chat_number, e, message_number, message_count)
  end

  def self.handle_creation_failure(application_token, chat_number, error, message_number, message_count)
    decrement_chat_message_number(application_token, chat_number) if message_number
    decrement_chat_messages_count(application_token, chat_number) if message_count
    raise
  end

  def self.search(application_token, chat_number, query)
    chat_id = ChatsDatastore.get_chat_id(application_token, chat_number)
    messages = ElasticSearchService.search(chat_id, query)
    if messages.empty?
      messages = MessageDatabaseRepository.search(chat_id, query)
      ElasticSearchService.index_messages(messages) unless messages.empty?
    end
    ElasticSearchService.format_results(messages)
  end

  def self.increment_chat_message_number(application_token, chat_number)
    MessageRedisRepository.increment_chat_message_number(application_token, chat_number)
  end

  def self.increment_chat_messages_count(application_token, chat_number)
    MessageRedisRepository.increment_chat_messages_count(application_token, chat_number)
  end

  def self.decrement_chat_message_number(application_token, chat_number)
    MessageRedisRepository.decrement_chat_message_number(application_token, chat_number)
  end

  def self.decrement_chat_messages_count(application_token, chat_number)
    MessageRedisRepository.decrement_chat_messages_count(application_token, chat_number)
  end

  def self.add_chat_needing_sync(application_token, chat_number)
    MessageRedisRepository.add_chat_needing_sync(application_token, chat_number)
  end

  def self.get_chat_last_message_number(application_token, chat_number)
    last_message_number = MessageRedisRepository.get_chat_message_number(application_token, chat_number)

    if last_message_number.nil?
      chat = ChatDatabaseRepository.get_chat(application_token, chat_number)
      last_message_number = MessageDatabaseRepository.max_message_number(chat)
      MessageRedisRepository.set_chat_message_number(application_token, chat_number, last_message_number)
    else
      last_message_number = last_message_number.to_i
    end
    last_message_number
  end

  def self.validate_chat_last_message_number(application_token, chat_number)
    last_message_number = MessageRedisRepository.get_chat_message_number(application_token, chat_number)

    if last_message_number.nil?
      chat = ChatDatabaseRepository.get_chat(application_token, chat_number)
      last_message_number = MessageDatabaseRepository.max_message_number(chat)
      MessageRedisRepository.set_chat_message_number(application_token, chat_number, last_message_number)
    end
  end
end
