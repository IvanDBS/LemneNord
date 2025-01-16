module MetricsService
  class << self
    def track_event(event_name, data = {})
      event = {
        event: event_name,
        timestamp: Time.now.in_time_zone('Europe/Chisinau'),
        data: data
      }

      RedisConfig::REDIS.with do |redis|
        redis.lpush("metrics:#{event_name}", event.to_json)
        redis.ltrim("metrics:#{event_name}", 0, 999) # храним последние 1000 событий
      end
    end

    def track_duration(operation)
      start_time = Time.now
      result = yield
      duration = Time.now - start_time
      
      track_event("#{operation}_duration", { ms: (duration * 1000).round(2) })
      
      result
    end
  end
end 