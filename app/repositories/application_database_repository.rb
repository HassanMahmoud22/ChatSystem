class ApplicationDatabaseRepository
  def self.create_application(application_name)
    application = Application.new(application_name)
    if application.save!
      application
    end
  end

  def self.get_application(application_token)
    application = Application.find_by(token: application_token)
    raise ActiveRecord::RecordNotFound, "Application not found" unless application

    application
  end

  def self.max_chat_number(application)
    application.chats.maximum(:chat_number) || 0
  end

  def self.update_application(token, name)
    application = get_application(token)
    if application.update!(name: name)
      application
    end
  end
end
