class JobManagerRedisRepository < RedisRepository
  def self.get_job_status(job_id, job_type)
    get("#{job_type}_creation_status:#{job_id}")
  end

  def self.get_job_result(job_id, job_type)
    get("#{job_type}_creation_result:#{job_id}").to_i
  end

  def self.handle_failed_job(job_id, job_type)
    error_message = get("#{job_type}_creation_error:#{job_id}")
    raise ErrorHandlingService.parse_error_message(error_message)
  end

end
