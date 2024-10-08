class MessageRedisRepository < RedisRepository
  def self.chat_message_number_key(application_token, chat_number)
    "#{application_key(application_token)}:#{CHAT_KEY_PREFIX}#{chat_number}:message_number"
  end

  def self.get_chat_messages_count(application_token, chat_number)
    chat_data = get_chat(application_token, chat_number)
    if chat_data
      chat_data["messages_count"].to_i
    end
  end

  def self.decrement_chat_message_number(application_token, chat_number)
    new_message_number = Redis.current.decr(chat_message_number_key(application_token, chat_number))
    Rails.logger.info("Decremented message number to #{new_message_number} for application token: #{application_token}")
    new_message_number
  end

  def self.increment_chat_message_number(application_token, chat_number)
    new_message_number = Redis.current.incr(chat_message_number_key(application_token, chat_number))
    Rails.logger.info("Incremented message number to #{new_message_number} for application token: #{application_token}")
    new_message_number
  end

  def self.get_chat_message_number(application_token, chat_number)
    get(chat_message_number_key(application_token, chat_number))
  end

  def self.set_chat_message_number(application_token, chat_number, message_number)
    set(chat_message_number_key(application_token, chat_number), message_number.to_s)
    Rails.logger.debug("Set new message number to #{message_number} for application token: #{application_token}")
  end

  def self.increment_chat_messages_count(application_token, chat_number)
    adjust_chat_messages_count(application_token, chat_number, 1)
  end

  def self.decrement_chat_messages_count(application_token, chat_number)
    adjust_chat_messages_count(application_token, chat_number, -1)
  end

  def self.add_chat_needing_sync(application_token, chat_number)
    Redis.current.sadd("chats_needing_sync", RedisRepository.chat_key(application_token, chat_number))
    Rails.logger.warn("added chat needing sync: #{chat_key(application_token, chat_number)}")
  rescue StandardError => e
    Rails.logger.error("Failed to add chat needing sync, error: #{e.message}")
  end

  def self.set_message_creation_result(job_id, message_number)
    set("message_creation_result:#{job_id}", message_number, ex: 60)
  end

  def self.set_message_creation_status(job_id, status)
    set("message_creation_status:#{job_id}", status)
  end

  def self.set_message_creation_error(job_id, error)
    set("message_creation_error:#{job_id}", error.to_s, ex: 60)
  end

  private

  def self.adjust_chat_messages_count(application_token, chat_number, adjustment)
    chat_data = get_chat(application_token, chat_number)

    if chat_data
      messages_count = chat_data["messages_count"].to_i + adjustment
      chat_data["messages_count"] = messages_count

      set(chat_key(application_token, chat_number), chat_data.to_json)
      Rails.logger.info("#{adjustment > 0 ? 'Incremented' : 'Decremented'} message count for application token: #{application_token}, chat number: #{chat_number}")
    else
      Rails.logger.warn("Couldn't adjust message count for token: #{application_token}, chat number: #{chat_number} - chat not found")
    end
  end
end
