require 'logger'

module ErrorHandler
  class << self
    def handle(bot, error, chat_id = nil)
      # Логируем ошибку
      puts "[ERROR] #{Time.now}: #{error.message}"
      puts error.backtrace.first(5)

      # Отправляем сообщение пользователю если указан chat_id
      if chat_id
        bot.api.send_message(
          chat_id: chat_id,
          text: "Произошла ошибка. Пожалуйста, попробуйте позже."
        )
      end
    end
  end
end 