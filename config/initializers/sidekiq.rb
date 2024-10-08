require "sidekiq"
require "sidekiq-cron"

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://redis:6379/0" }
end

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://redis:6379/0" }

  # Additional server-side configuration, if any, can go here
end