class RedisRepository
  APPLICATION_KEY_PREFIX = "application:"
  CHAT_KEY_PREFIX = "chat:"

  # Key generation methods
  def self.application_key(token)
    "#{APPLICATION_KEY_PREFIX}#{token}"
  end

  def self.chat_key(application_token, chat_number)
    "#{APPLICATION_KEY_PREFIX}#{application_token}:#{CHAT_KEY_PREFIX}#{chat_number}"
  end

  def self.chat_message_number_key(application_token, chat_number)
    "#{APPLICATION_KEY_PREFIX}#{application_token}:#{CHAT_KEY_PREFIX}#{chat_number}:message_number"
  end

  # Redis operations
  def self.set(key, value, expiry = nil)
    Redis.current.set(key, value, ex: expiry)
  rescue StandardError => e
    Rails.logger.error("Failed to set key: #{key}, error: #{e.message}")
    raise
  end

  def self.get(key)
    Redis.current.get(key)
  rescue StandardError => e
    Rails.logger.error("Failed to get key: #{key}, error: #{e.message}")
    nil
  end

  def self.delete(key)
    Redis.current.del(key)
  rescue StandardError => e
    Rails.logger.error("Failed to delete key: #{key}, error: #{e.message}")
  end

  def self.get_application_by_token(application_token)
    Rails.logger.info("Fetching application by token: #{application_token}")
    data = get(application_key(application_token))
    return nil unless data
    JSON.parse(data)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse application data for token: #{application_token}, error: #{e.message}")
    nil
  end

  def self.get_chat(application_token, chat_number)
    Rails.logger.info("Fetching chat for chat number: #{chat_number}")
    chat = get(chat_key(application_token, chat_number))

    return nil unless chat

    JSON.parse(chat)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse chat data for application token: #{application_token}, chat number: #{chat_number}, error: #{e.message}")
    nil
  end
end
