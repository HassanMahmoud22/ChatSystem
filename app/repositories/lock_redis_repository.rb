class LockRedisRepository < RedisRepository
  def self.lock_key(application_token, chat_number)
    "lock:message_creation:#{application_token}:#{chat_number}"
  end

  def self.acquire_lock(application_token, chat_number)
    retries = 0
    max_retries = 5
    wait_time = 2

    while retries < max_retries
      if Redis.current.set(lock_key(application_token, chat_number), "true", ex: 5)
        Rails.logger.info("Lock acquired for #{lock_key(application_token, chat_number)}")
        result = yield
        release_lock(application_token, chat_number)
        return result
      else
        Rails.logger.warn("Lock is already held. Retrying... (Attempt #{retries + 1})")
        sleep(wait_time)
        retries += 1
      end
    end
    handle_lock_failure(application_token, chat_number, max_retries)
  end

  private

  def self.release_lock(application_token, chat_number)
    Redis.current.del(lock_key(application_token, chat_number))
    Rails.logger.info("Lock released for #{lock_key(application_token, chat_number)}")
  end

  def self.handle_lock_failure(application_token, chat_number, max_retries)
    Rails.logger.error("Failed to acquire lock after #{max_retries} attempts for #{lock_key(application_token, chat_number)}")
    raise "Unable to acquire lock for #{application_token} and chat #{chat_number} after #{max_retries} attempts"
  end
end
