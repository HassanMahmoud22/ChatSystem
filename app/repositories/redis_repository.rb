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

  # def self.set_application(application)
  #   application_data = {
  #     id: application.id,
  #     token: application.token,
  #     name: application.name,
  #     chat_count: application.chats.count
  #   }.to_json
  #
  #   set(application_key(application.token), application_data)
  #   Rails.logger.info("Stored application in Redis for token: #{application.token}")
  # end
  #
  # def self.get_application_by_token(application_token)
  #   Rails.logger.info("Fetching application by token: #{application_token}")
  #   data = get(application_key(application_token))
  #
  #   return nil unless data
  #
  #   JSON.parse(data)
  # rescue JSON::ParserError => e
  #   Rails.logger.error("Failed to parse application data for token: #{application_token}, error: #{e.message}")
  #   nil
  # end
  #
  # def self.increment_application_chat_count(application_token)
  #   adjust_application_chat_count(application_token, 1)
  # end
  #
  # def self.decrement_application_chat_count(application_token)
  #   adjust_application_chat_count(application_token, -1)
  # end
  #
  # def self.get_application_chat_count(application_token)
  #   application = get_application_by_token(application_token)
  #   application ? application["chat_count"].to_i : nil
  # end
  #
  # def self.add_application_needing_sync(application_id)
  #   Redis.current.sadd("applications_needing_sync", application_id.to_s)
  # rescue StandardError => e
  #   Rails.logger.error("Failed to add application needing sync: #{application_id}, error: #{e.message}")
  # end
  #
  # def self.add_chat_needing_sync(chat_id)
  #   Redis.current.sadd("chats_needing_sync", chat_id.to_s)
  # rescue StandardError => e
  #   Rails.logger.error("Failed to add chat needing sync: #{chat_id}, error: #{e.message}")
  # end
  #
  # def self.initialize_chat_number(application_token)
  #   set("#{application_key(application_token)}:chat_number", "0")
  #   Rails.logger.debug("Initialized chat number to 0 for application token: #{application_token}")
  # end
  #
  # def self.get_application_chat_number(application_token)
  #   get("#{application_key(application_token)}:chat_number")
  # end
  #
  # def self.set_application_chat_number(application_token, chat_number)
  #   set("#{application_key(application_token)}:chat_number", chat_number.to_s)
  #   Rails.logger.debug("Set new chat number to #{chat_number} for application token: #{application_token}")
  # end
  #
  # def self.increment_application_chat_number(application_token)
  #   new_chat_number = Redis.current.incr("#{application_key(application_token)}:chat_number")
  #   Rails.logger.info("Incremented chat number to #{new_chat_number} for application token: #{application_token}")
  #   new_chat_number
  # end
  #
  # def self.decrement_application_chat_number(application_token)
  #   new_chat_number = Redis.current.decr("#{application_key(application_token)}:chat_number")
  #   Rails.logger.info("Decremented chat number to #{new_chat_number} for application token: #{application_token}")
  #   new_chat_number
  # end

  # def self.get_chat(application_token, chat_number)
  #   Rails.logger.info("Fetching chat for chat number: #{chat_number}")
  #   chat = get(chat_key(application_token, chat_number))
  #
  #   return nil unless chat
  #
  #   JSON.parse(chat)
  # rescue JSON::ParserError => e
  #   Rails.logger.error("Failed to parse chat data for application token: #{application_token}, chat number: #{chat_number}, error: #{e.message}")
  #   nil
  # end

  # def self.set_chat(application_token, chat)
  #   chat_data = {
  #     id: chat.id,
  #     messages_count: chat.messages.count
  #   }.to_json
  #
  #   set(chat_key(application_token, chat.chat_number), chat_data)
  #   Rails.logger.info("Stored chat in Redis for application token: #{application_token}, chat number: #{chat.chat_number}")
  # end

  # def self.decrement_chat_messages_count(application_token, chat_number)
  #   adjust_chat_messages_count(application_token, chat_number, -1)
  # end

  # def self.increment_chat_messages_count(application_token, chat_number)
  #   adjust_chat_messages_count(application_token, chat_number, 1)
  # end

  # def self.decrement_chat_message_number(application_token, chat_number)
  #   new_chat_number = Redis.current.decr(chat_message_number_key(application_token, chat_number))
  #   Rails.logger.info("Decremented message number to #{new_chat_number} for application token: #{application_token}")
  #   new_chat_number
  # end
  #
  # def self.increment_chat_message_number(application_token, chat_number)
  #   new_message_number = Redis.current.incr(chat_message_number_key(application_token, chat_number))
  #   Rails.logger.info("Incremented message number to #{new_message_number} for application token: #{application_token}")
  #   new_message_number
  # end
  #
  # def self.get_chat_message_number(application_token, chat_number)
  #   get(chat_message_number_key(application_token, chat_number))
  # end
  #
  # def self.set_chat_message_number(application_token, chat_number, message_number)
  #   set(chat_message_number_key(application_token, chat_number), message_number.to_s)
  #   Rails.logger.debug("Set new message number to #{message_number} for application token: #{application_token}")
  # end

  private

  # def self.adjust_application_chat_count(application_token, adjustment)
  #   application_data = get_application_by_token(application_token)
  #
  #   if application_data
  #     chat_count = application_data["chat_count"].to_i + adjustment
  #     application_data["chat_count"] = chat_count
  #
  #     set(application_key(application_token), application_data.to_json)
  #     Rails.logger.info("#{adjustment > 0 ? 'Incremented' : 'Decremented'} chat count for token: #{application_token}")
  #   else
  #     Rails.logger.warn("Couldn't adjust chat count for token: #{application_token} - application not found")
  #   end
  # end

  # def self.adjust_chat_messages_count(application_token, chat_number, adjustment)
  #   chat_data = get_chat(application_token, chat_number)
  #
  #   if chat_data
  #     messages_count = chat_data["messages_count"].to_i + adjustment
  #     chat_data["messages_count"] = messages_count
  #
  #     set(chat_key(application_token, chat_number), chat_data.to_json)
  #     Rails.logger.info("#{adjustment > 0 ? 'Incremented' : 'Decremented'} message count for application token: #{application_token}, chat number: #{chat_number}")
  #   else
  #     Rails.logger.warn("Couldn't adjust message count for token: #{application_token}, chat number: #{chat_number} - chat not found")
  #   end
  # end
end
