# app/services/job_manager_service.rb
class JobManagerService
  TIMEOUT = 10
  SLEEP_TIME = 1

  def self.wait_for_job_completion(job_id, job_type)
    elapsed_time = 0

    while elapsed_time < TIMEOUT
      job_status = JobManagerRedisService.get_job_status(job_id, job_type)
      return JobManagerRedisService.get_job_result(job_id, job_type) if job_status == "success"

      if job_status == "failed"
        JobManagerRedisService.handle_failed_job(job_id, job_type)
      end

      sleep(SLEEP_TIME)
      elapsed_time += SLEEP_TIME
    end

    raise "#{job_type.capitalize} creation timed out"
  end

  def self.enqueue_job(job_class, *args)
    job_class.perform_later(*args)
  end

  def self.generate_job_id
    SecureRandom.uuid
  end

  private


end
