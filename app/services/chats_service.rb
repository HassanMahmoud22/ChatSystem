# app/services/chats_service.rb
class ChatsService

  def initialize(application_token)
    @application_token = application_token
  end

  def create_chat
    job_id = JobManagerService.generate_job_id
    JobManagerService.enqueue_job(ChatCreationJob, @application_token, job_id)
    JobManagerService.wait_for_job_completion(job_id, "chat")
  end

  def application_chats
    ChatsDatastore.get_application_chats(@application_token)
  end
end

