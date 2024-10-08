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
  end

  def self.increment_application_chat_number(application_token)
    Redis.current.incr("#{application_key(application_token)}:chat_number")
  end

  def self.decrement_application_chat_number(application_token)
    Redis.current.decr("#{application_key(application_token)}:chat_number")
  end

  def self.add_application_needing_sync(application_token)
    Redis.current.sadd("applications_needing_sync", application_token)
  rescue StandardError => e
    Rails.logger.error("Failed to add application needing sync: #{application_token}, error: #{e.message}")
  end

  def self.set_chat_creation_result(job_id, chat_number)
    set("chat_creation_result:#{job_id}", chat_number, 60)
  end

  def self.set_chat_creation_status(job_id, status)
    set("chat_creation_status:#{job_id}", status)
  end

  def self.set_chat_creation_error(job_id, error)
    set("chat_creation_error:#{job_id}", error.to_s, ex: 60)
  end

  def self.remove_chat_from_needing_sync(chat_key)
    Redis.current.srem("chats_needing_sync", chat_key)
  end

  private

  def self.adjust_application_chat_count(application_token, adjustment)
    application_data = get_application_by_token(application_token)

    if application_data
      chat_count = application_data["chat_count"].to_i + adjustment
      application_data["chat_count"] = chat_count
      set(application_key(application_token), application_data.to_json)
    else
      Rails.logger.warn("Couldn't adjust chat count for token: #{application_token} - application not found")
    end
  end
end
