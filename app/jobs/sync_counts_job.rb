class SyncCountsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.warn "Syncing counts"
    sync_applications
    sync_chats
  rescue StandardError => e
    Rails.logger.error "Failed to sync counts: #{e.message}"
  end

  private

  def sync_applications
    application_tokens = Redis.current.smembers("applications_needing_sync")
    application_tokens.each do |application_token|
      application = Application.find_by(token: application_token)
      chat_count = ApplicationRedisRepository.get_application_chat_count(application_token)
      if chat_count && chat_count != 0 && application.chats_count != chat_count
        application.update!(chats_count: chat_count)
      end
      ApplicationRedisRepository.remove_application_from_needing_sync(application_token)
    end
  end

  def sync_chats
    chat_keys = Redis.current.smembers("chats_needing_sync")
    chat_keys.each do |chat_key|
      redis_chat = RedisRepository.get(chat_key)
      if redis_chat
        redis_chat = JSON.parse(redis_chat)
        chat_id = redis_chat["id"].to_i
        chat = Chat.find(chat_id)
        messages_count = redis_chat["messages_count"]
        if messages_count && messages_count != 0 && chat.messages_count != messages_count
          chat.update!(messages_count: messages_count)
          Rails.logger.info "Updated Chat #{chat.id}: messages_count set to #{messages_count}"
        end
      else
        Rails.logger.warn "The Chat is no longer in memory"
      end
      ChatRedisRepository.remove_chat_from_needing_sync(chat_key)
    end
  end
end
