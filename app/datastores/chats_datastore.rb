class ChatDatastore

  def self.get_application_id_by_token(application_token)
    application_data = RedisService.get_application_by_token(application_token)
    if application_data.nil?
      application = ApplicationRepository.get_application(application_token)
      application_id = application.id
      Rails.logger.warn "getting from database application id is: #{application_id}"
      Rails.logger.warn "setting application in redis with token: #{application_token}"
      RedisService.set_application(application)
    else
      application_id = application_data["id"]
      Rails.logger.warn "Application id retrieved from Redis: #{application_id}"
    end
    application_id
  end

  def self.create_chat_and_update_counts(application_id, application_token)
    lock_key = "lock:chat_creation:#{application_token}"
    if Redis.current.set(lock_key, "true", nx: true, ex: 5)
      begin
        ApplicationRecord.transaction do

          # Increment the chat number in Redis
          chat_number = increment_chat_number(application_token)

          # Create the chat with the given chat_number
          ChatRepository.create_chat(application_id, chat_number)

          # Increment the chat count in Redis
          increment_chat_count(application_token)

          # Mark this application as needing a sync
          add_application_needing_sync(application_id)
        end
      ensure
        # Release the lock after processing
        Redis.current.del(lock_key)
      end
    end
  rescue StandardError => e
    Rails.logger.error "Failed to create chat and update counts: #{e.message}"
    raise
  end

  def self.get_last_chat_number(application_token)
    last_chat_number = RedisService.get_chat_number(application_token)

    if last_chat_number.nil?
      application = ApplicationRepository.get_application(application_token)
      last_chat_number = ApplicationRepository.max_chat_number(application)
      Rails.logger.warn("Getting chat number from database = #{last_chat_number} for application token: #{application_token}")
      RedisService.set_chat_number(application_token, last_chat_number)
    else
      last_chat_number = last_chat_number.to_i
    end
    last_chat_number
  end

  def self.increment_chat_number(application_token)
    RedisService.increment_chat_number(application_token)
  end

  def self.increment_chat_count(application_token)
    RedisService.increment_chat_count(application_token)
  end

  def self.add_application_needing_sync(application_id)
    RedisService.add_application_needing_sync(application_id)
  end

  def self.get_application_chats(application_token)
    application = Application.find_by(token: application_token)
    raise ActiveRecord::RecordNotFound, "Application not found" unless application
    application.chats
  end

end
