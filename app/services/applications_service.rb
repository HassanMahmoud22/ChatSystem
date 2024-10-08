class ApplicationsService
  def create_application(application_name)
    ApplicationsDatastore.create_application(application_name)
  end

  def get_application(token)
    ApplicationsDatastore.get_application(token)
  end

  def update_application(token, name)
    ApplicationsDatastore.update_application(token, name)
  end
end
