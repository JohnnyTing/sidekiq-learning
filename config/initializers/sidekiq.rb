# frozen_string_literal: true

redis = YAML.load_file('config/redis.yml')[Rails.env]
redis_server = redis['redis_server']
redis_port = redis['redis_port']
redis_db_num = redis['redis_db_num']
redis_namespace = redis['redis_namespace']
# password = redis['redis_password']

redis_url = "redis://#{redis_server}:#{redis_port}/#{redis_db_num}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: redis_namespace }
  # config.redis = { url: redis_url, namespace: redis_namespace, password: password }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: redis_namespace }
  # config.redis = { url: redis_url, namespace: redis_namespace, password: password }
end

schedule_file = 'config/schedule.yml'

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
