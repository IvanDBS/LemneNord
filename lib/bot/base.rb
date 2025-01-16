require 'telegram/bot'
require 'active_record'

class Bot
  def initialize(token, admin_ids)
    @token = token
    @admin_ids = admin_ids
  end

  def start
    Telegram::Bot::Client.run(@token) do |bot|
      puts "Bot started"
      
      bot.listen do |message|
        begin
          handle_update(bot, message)
        rescue => e
          puts "Error: #{e.message}"
          puts e.backtrace
        end
      end
    end
  end

  private

  def handle_update(bot, message)
    case message
    when Telegram::Bot::Types::Message
      MessageHandler.new(bot, message, @admin_ids).handle
    when Telegram::Bot::Types::CallbackQuery
      CallbackHandler.new(bot, message, @admin_ids).handle
    end
  end
end 