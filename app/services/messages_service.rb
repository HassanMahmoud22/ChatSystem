class MessagesService
  def create(application_token, chat_number, message_body)
    job_id = SecureRandom.uuid
    JobManagerService.enqueue_job(MessageCreationJob, application_token, chat_number, message_body, job_id)
    JobManagerService.wait_for_job_completion(job_id, "message")
  end

  def get_chat_messages(application_token, chat_number)
    MessagesDatastore.get_chat_messages(application_token, chat_number)
  end

  def search(application_token, chat_number, query)
    MessagesDatastore.search(application_token, chat_number, query)
  end
end
