require 'rufus-scheduler'
require_relative 'config'
require_relative 'lib/bot/services/admin_services'
require_relative 'lib/bot/services/error_handler'

scheduler = Rufus::Scheduler.new

# Мониторинг состояния бота
scheduler.every '5m' do
  begin
    bot = Telegram::Bot::Client.new(Config::TELEGRAM_TOKEN)
    bot_info = bot.api.get_me
    
    # Проверяем соединение с БД
    ActiveRecord::Base.connection.execute("SELECT 1")
    
    # Логируем успешную проверку
    puts "[#{Time.now}] Bot health check: OK"
  rescue => e
    ErrorHandler.handle(bot, e)
  end
end

# Ежедневная статистика админам
scheduler.cron Config::SCHEDULER_CONFIG[:stats_time] do
  begin
    bot = Telegram::Bot::Client.new(Config::TELEGRAM_TOKEN)
    
    Config::ADMIN_IDS.each do |admin_id|
      AdminServices.show_statistics(bot, admin_id)
    end
  rescue => e
    puts "Scheduler error: #{e.message}"
    puts e.backtrace
  end
end

# Держим процесс запущенным
scheduler.join 