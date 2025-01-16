module RedisConfig
  REDIS = ConnectionPool.new(size: 5, timeout: 5) do
    Redis.new(url: ENV['REDIS_URL'])
  end
end 