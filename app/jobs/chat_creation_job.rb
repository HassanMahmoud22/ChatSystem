class ChatCreationJob < ApplicationJob
  queue_as :default

  def perform(application_token, job_id)
    chat_number = ChatsDatastore.create_chat_and_update_counts(application_token)
    ChatRedisRepository.set_chat_creation_result(job_id, chat_number)
    ChatRedisRepository.set_chat_creation_status(job_id, "success")
  rescue StandardError => e
    Rails.logger.error "Chat creation failed: #{e.message}"
    ChatRedisRepository.set_chat_creation_status(job_id, "failed")
    ChatRedisRepository.set_chat_creation_error(job_id, e)
    raise
  end
end
