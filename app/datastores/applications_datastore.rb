class ApplicationsDatastore
  def self.create_application(application_name)
    ApplicationRecord.transaction do
      application = ApplicationDatabaseRepository.create_application(application_name)
      ApplicationRedisRepository.set_application(application)
      ApplicationRedisRepository.initialize_chat_number(application.token)
      application
    end
  end

  def self.get_application(token)
    application = ApplicationRedisRepository.get_application_by_token(token)
    if application.nil?
      application = ApplicationDatabaseRepository.get_application(token)
      ApplicationRedisRepository.set_application(application)
    else
      application.delete("id")
    end
    application
  end

  def self.get_application_id_by_token(application_token)
    application_data = ApplicationRedisRepository.get_application_by_token(application_token)
    if application_data
      return application_data["id"].to_i
    end
    application = ApplicationDatabaseRepository.get_application(application_token)
    if application
      ApplicationRedisRepository.set_application(application)
      return application.id
    end
    Rails.logger.error("Application not found with application_token: #{application_token}")
    raise ActiveRecord::RecordNotFound, "Application not found"
  end

  def self.update_application(token, name)
    application = ApplicationDatabaseRepository.update_application(token, name)
    ApplicationRedisRepository.set_application(application)
    chat_count = ApplicationRedisRepository.get_application_chat_count(token)
    application.chats_count = chat_count unless chat_count.nil?
    application
  end

  def self.get_application_last_chat_number(application_token)
    last_chat_number = ChatRedisRepository.get_application_chat_number(application_token)
    if last_chat_number.nil?
      application = ApplicationDatabaseRepository.get_application(application_token)
      last_chat_number = ApplicationDatabaseRepository.max_chat_number(application)
      ChatRedisRepository.set_application_chat_number(application_token, last_chat_number)
    else
      last_chat_number = last_chat_number.to_i
    end
    last_chat_number
  end

  def self.validate_application_last_chat_number(application_token)
    last_chat_number = ChatRedisRepository.get_application_chat_number(application_token)
    if last_chat_number.nil?
      application = ApplicationDatabaseRepository.get_application(application_token)
      last_chat_number = ApplicationDatabaseRepository.max_chat_number(application)
      ChatRedisRepository.set_application_chat_number(application_token, last_chat_number)
    end
  end
end
