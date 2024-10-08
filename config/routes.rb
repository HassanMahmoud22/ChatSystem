Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # API routes for the chat system
      resources :applications, only: [ :create, :show, :update ], param: :token do
        resources :chats, only: [ :create, :index ], param: :chat_number do
          resources :messages, only: [ :create, :index ] do
            collection do
              get :search, to: "messages#search"  # Use symbol for search route
            end
          end
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
