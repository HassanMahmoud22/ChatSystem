class ApplicationDatastore
  def self.create_application(application_name)
    ApplicationRecord.transaction do
      application = ApplicationRepository.create_application(application_name)
      RedisService.set_application(application)
      RedisService.initialize_chat_number(application.token)
      application
    end
  end

  def self.get_application(token)
    application = RedisService.get_application_by_token(token)
    if application.nil?
      application = ApplicationRepository.get_application(token)
      RedisService.set_application(application)
      Rails.logger.debug("Fetched chat_count from the database = #{application.chats.count}")
    end
    application
  end

  def self.update_application(token, name)
    application = ApplicationRepository.update_application(token, name)
    RedisService.set_application(application)
    chat_count = RedisService.get_chat_count(token)
    application.chats_count = chat_count unless chat_count.nil?
    application
  end
end
