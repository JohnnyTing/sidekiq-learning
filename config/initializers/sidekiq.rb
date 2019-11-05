# frozen_string_literal: true

redis = YAML.load_file('config/redis.yml')[Rails.env]
redis_server = redis['redis_server']
redis_port = redis['redis_port']
redis_db_num = redis['redis_db_num']
redis_namespace = redis['redis_namespace']
# user_name = redis['user_name']
# password = redis['user_password']

Sidekiq.configure_server do |config|
  p redis_server
  config.redis = { url: "redis://#{redis_server}:#{redis_port}/#{redis_db_num}", namespace: redis_namespace }
  # config.redis = { url: "redis://#{redis_server}:#{redis_port}/#{redis_db_num}", namespace: redis_namespace, password: password }
  # config.redis = { url: "redis://#{user_name}:#{password}@#{redis_server}:#{redis_port}/#{redis_db_num}", namespace: redis_namespace }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{redis_server}:#{redis_port}/#{redis_db_num}", namespace: redis_namespace }
  # config.redis = { url: "redis://#{redis_server}:#{redis_port}/#{redis_db_num}", namespace: redis_namespace, password: password }
  # config.redis = { url: "redis://#{user_name}:#{password}@#{redis_server}:#{redis_port}/#{redis_db_num}", namespace: redis_namespace }
end

schedule_file = 'config/schedule.yml'

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
