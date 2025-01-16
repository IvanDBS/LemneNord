class BroadcastJob < ApplicationJob
  def perform(user_id, message_text)
    user = User.find(user_id)
    bot = Telegram::Bot::Client.new(Config::TELEGRAM_TOKEN)
    
    bot.api.send_message(
      chat_id: user.telegram_id,
      text: message_text
    )
  rescue => e
    ErrorHandler.handle(bot, e)
  end
end 