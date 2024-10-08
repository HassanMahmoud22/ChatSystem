class ChatRedisRepository < RedisRepository

  def self.chat_key(application_token, chat_number)
    "#{application_key(application_token)}:#{CHAT_KEY_PREFIX}#{chat_number}"
  end

  def self.set_chat(application_token, chat)
    chat_data = {
      id: chat.id,
      messages_count: chat.messages.count
    }.to_json

    set(chat_key(application_token, chat.chat_number), chat_data)
    Rails.logger.info("Stored chat in Redis for application token: #{application_token}, chat number: #{chat.chat_number}")
  end

  def self.increment_application_chat_count(application_token)
    adjust_application_chat_count(application_token, 1)
  end

  def self.decrement_application_chat_count(application_token)
    adjust_application_chat_count(application_token, -1)
  end

  def self.get_application_chat_number(application_token)
    get("#{application_key(application_token)}:chat_number")
  end

  def self.set_application_chat_number(application_token, chat_number)
    set("#{application_key(application_token)}:chat_number", chat_number.to_s)
    Rails.logger.debug("Set new chat number to #{chat_number} for application token: #{application_token}")
  end

  def self.increment_application_chat_number(application_token)
    new_chat_number = Redis.current.incr("#{application_key(application_token)}:chat_number")
    Rails.logger.info("Incremented chat number to #{new_chat_number} for application token: #{application_token}")
    new_chat_number
  end

  def self.decrement_application_chat_number(application_token)
    new_chat_number = Redis.current.decr("#{application_key(application_token)}:chat_number")
    Rails.logger.info("Decremented chat number to #{new_chat_number} for application token: #{application_token}")
    new_chat_number
  end

  def self.add_application_needing_sync(application_id)
    Redis.current.sadd("applications_needing_sync", application_id.to_s)
  rescue StandardError => e
    Rails.logger.error("Failed to add application needing sync: #{application_id}, error: #{e.message}")
  end

  private

  def self.adjust_application_chat_count(application_token, adjustment)
    application_data = get_application_by_token(application_token)

    if application_data
      chat_count = application_data["chat_count"].to_i + adjustment
      application_data["chat_count"] = chat_count

      set(application_key(application_token), application_data.to_json)
      Rails.logger.info("#{adjustment > 0 ? 'Incremented' : 'Decremented'} chat count for token: #{application_token}")
    else
      Rails.logger.warn("Couldn't adjust chat count for token: #{application_token} - application not found")
    end
  end
end
