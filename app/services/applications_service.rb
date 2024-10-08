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

  # def get_application(token)
  #   application = RedisService.get_application_by_token(params[:token])
  #   if application.nil?
  #       application = ApplicationRepository.get_application(token)
  #       Application.find_by(token: params[:token])
  #       if @application
  #         # Cache chat_count in Redis if it is not already present
  #         chat_count = @application.chats.count
  #         Redis.current.set("application:#{@application.id}:chat_count", chat_count.to_s)
  #         Rails.logger.debug("Fetched chat_count from the database = #{chat_count}")
  #       end
  #     else
  #       Rails.logger.debug("Fetched application from Redis = #{@application}")
  #     end
  #
  #     if @application
  #       # Now you can include the chat_count in the response
  #       chat_count = Redis.current.get("application:#{@application.id}:chat_count").to_i
  #       render json: { application: @application, chat_count: chat_count }, status: :ok
  #     else
  #       render json: { error: "Application not found" }, status: :not_found
  #     end
  #   end

end
