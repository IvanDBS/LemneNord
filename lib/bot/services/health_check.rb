module HealthCheck
  class << self
    def check
      {
        db: check_database,
        redis: check_redis,
        bot: check_bot,
        sidekiq: check_sidekiq
      }
    end

    private

    def check_database
      ActiveRecord::Base.connection.execute("SELECT 1")
      true
    rescue => e
      false
    end

    def check_redis
      RedisConfig::REDIS.with { |redis| redis.ping == 'PONG' }
    rescue => e
      false
    end

    def check_bot
      bot = Telegram::Bot::Client.new(Config::TELEGRAM_TOKEN)
      bot.api.get_me.present?
    rescue => e
      false
    end

    def check_sidekiq
      Sidekiq::ProcessSet.new.size > 0
    rescue => e
      false
    end
  end
end 