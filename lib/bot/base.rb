require 'telegram/bot'
require 'active_record'
require_relative 'handlers/message_handler'
require_relative 'handlers/callback_handler'

class Bot
  def initialize(token, admin_ids)
    puts "Initializing bot with admin IDs: #{admin_ids.inspect}"
    puts "Token starts with: #{token[0..5]}"
    @token = token
    @admin_ids = admin_ids
  end

  def start
    puts "Starting bot with Telegram::Bot::Client..."
    Telegram::Bot::Client.run(@token) do |bot|
      puts "Bot successfully connected to Telegram API"
      bot_info = bot.api.get_me
      puts "Bot info: #{bot_info.inspect}"
      puts "Bot username: #{bot_info['result']['username']}"
      
      bot.listen do |message|
        begin
          puts "\nReceived update type: #{message.class}"
          puts "From user: #{message.from&.id}"
          puts "Chat ID: #{message.chat&.id}"
          if message.is_a?(Telegram::Bot::Types::Message)
            puts "Message text: #{message.text.inspect}"
          end
          handle_update(bot, message)
        rescue => e
          puts "Error handling message: #{e.message}"
          puts "Error class: #{e.class}"
          puts e.backtrace
        end
      end
    end
  rescue => e
    puts "Critical error in bot execution: #{e.message}"
    puts "Error class: #{e.class}"
    puts e.backtrace
    raise e
  end

  private

  def handle_update(bot, message)
    case message
    when Telegram::Bot::Types::Message
      puts "Handling message from user #{message.from.id}"
      MessageHandler.new(bot, message, @admin_ids).handle
    when Telegram::Bot::Types::CallbackQuery
      puts "Handling callback query from user #{message.from.id}"
      CallbackHandler.new(bot, message, @admin_ids).handle
    else
      puts "Unhandled update type: #{message.class}"
    end
  rescue => e
    puts "Error in handle_update: #{e.message}"
    puts e.backtrace
    raise e
  end
end 