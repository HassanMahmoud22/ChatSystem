class MessageCreationJob < ApplicationJob
  queue_as :default

  def perform(application_token, chat_number, message_body, job_id)
    message_number = MessagesDatastore.create_message_and_update_counts(application_token, chat_number, message_body)
    MessageRedisRepository.set_message_creation_result(job_id, message_number)
    MessageRedisRepository.set_message_creation_status(job_id, "success")
  rescue StandardError => e
    Rails.logger.error "Message creation failed: #{e.message}"
    MessageRedisRepository.set_message_creation_status(job_id, "failed")
    MessageRedisRepository.set_message_creation_error(job_id, e)
    raise
  end
end
