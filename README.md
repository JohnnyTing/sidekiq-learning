<h1 align="center">Welcome to sidekiq-learning 👋</h1>
<p>
  <img src="https://img.shields.io/badge/version-1.0.0-blue.svg?cacheSeconds=2592000" />
  <a href="https://github.com/JohnnyTing/sidekiq-learning/blob/master/README.md">
    <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg" target="_blank" />
  </a>
</p>

> sidekiq-quick-start

## Install

```sh
bundle
```
## Usage
reference: 

[sidekiq官方文档](https://github.com/mperham/sidekiq/wiki)

[ruby-china](https://ruby-china.org/topics/19891)

[sidekiq-cron](https://github.com/ondrejbartas/sidekiq-cron)

1.本地安装redis，macos这里使用homebrew安装

```shell
=> brew install redis

To have launchd start redis now and restart at login:
 brew services start redis
Or, if you don't want/need a background service you can just run:
 redis-server /usr/local/etc/redis.conf
 
安装后的redis命令在/usr/local/bin目录下
```

2.启动redis server

```shell
# 后台启动
brew services start redis

# 非后台启动
redis-server /usr/local/etc/redis.conf

# 停止
brew services stop redis
```

3.启动redis cli

```shell
$ redis-cli

> keys *
> flushall
```

4.在Gemfile中添加sidekiq gem

```ruby
# 当需要给redis添加namespace时，需要这个gem
gem 'redis-namespace'
gem 'sidekiq'
```

5.在app/workers添加hard_worker.rb

```ruby
class HardWorker
 include Sidekiq::Worker
 def perform(name, count)
 sleep(count)
 pp "hello #{name}"
 end
end

# 调用方式
# 阻塞
HardWorker.new.perform("redis",10)
# 非阻塞
HardWorker.perform_async('redis', 10)
```

6.定义redis配置信息: config/redis.yml

```yml
redis: &redis
 redis_server: 'localhost'
 redis_port: 6378
 redis_db_num: 1
 redis_namespace: 'redis_sidekiq'
# redis_password: sidekiq
development:
 <<: *redis
production:
 <<: *redis
```

7.添加sidekiq初始化配置: config/initializers/sidekiq.rb

```ruby
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

```

8.定义sidekiq默认启动配置config/sidekiq.yml

```yml
:concurrency: 5
:queues:
 - default
 - [hard_worker, 2]
development:
 :concurrency: 5
staging:
 :concurrency: 10
production:
 :concurrency: 20
```

9.配置在routes.rb 配置sidekiq web-ui

```ruby
require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'
```

10.启动sidekiq

```shell
bundle exec sidekiq -C config/sidekiq.yml
```

11.添加cron定时任务，Gemfile:

```ruby
gem "sidekiq-cron", "~> 1.1"
```

12.定时任务配置config/schedule.yml，每一分钟调用HardWorker的perform方法，args传递多个参数（array or hash）

```yml
first_job:
 cron: "*/1 * * * *"
 class: "HardWorker"
 queue: "hard_worker"
 args:
 - "cron"
 - 10
```

13.在初始化sidekiq时添加如下内容initializers/sidekiq.rb

```ruby
schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
 Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
```

14.将cron添加到sidekiq-web-ui中

```ruby
require 'sidekiq/web'
require 'sidekiq/cron/web'
mount Sidekiq::Web => '/sidekiq'
```

## Author

👤 **JohnnyTing**

* Github: [@JohnnyTing](https://github.com/JohnnyTing)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/JohnnyTing/sidekiq-learning/issues).

## Show your support

Give a ⭐️ if this project helped you!

***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_
