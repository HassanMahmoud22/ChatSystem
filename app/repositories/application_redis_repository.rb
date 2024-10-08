class ApplicationRedisRepository < RedisRepository

  def self.set_application(application)
    application_data = {
      id: application.id,
      token: application.token,
      name: application.name,
      chat_count: application.chats.count
    }.to_json
    set(application_key(application.token), application_data)
  end

  def self.initialize_chat_number(application_token)
    set("#{application_key(application_token)}:chat_number", "0")
  end

  def self.increment_chat_count(application_token)
    adjust_chat_count(application_token, 1)
  end

  def self.decrement_chat_count(application_token)
    adjust_chat_count(application_token, -1)
  end

  def self.get_application_chat_count(application_token)
    application = get_application_by_token(application_token)
    application ? application["chat_count"].to_i : nil
  end

  def remove_application_from_needing_sync(application_token)
    Redis.current.srem("applications_needing_sync", application_token)
  end

  private

  def self.adjust_chat_count(application_token, adjustment)
    application_data = get_application_by_token(application_token)
    if application_data
      chat_count = application_data["chat_count"].to_i + adjustment
      application_data["chat_count"] = chat_count
      RedisRepository.set(application_key(application_token), application_data.to_json)
    else
      Rails.logger.warn("Couldn't adjust chat count for token: #{application_token} - application not found")
    end
  end
end
