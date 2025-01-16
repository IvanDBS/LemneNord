# Клавиатуры для админа
module AdminKeyboard
  class << self
    def menu
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: [
          [
            { text: '📊 Статистика' }
          ],
          [
            { text: '⏳ Ожидающие' },
            { text: '✅ Принятые' },
            { text: '❌ Отклоненные' }
          ],
          [
            { text: '📢 Рассылка' },
            { text: '📢 Сообщение в канал' }
          ]
        ],
        resize_keyboard: true
      )
    end

    def show_menu(bot, message)
      bot.api.send_message(
        chat_id: message.chat.id,
        text: '🔑 Панель администратора:',
        reply_markup: menu
      )
    end

    def application_buttons(application_id)
      Telegram::Bot::Types::InlineKeyboardMarkup.new(
        inline_keyboard: [
          [
            { text: '✅ Принять', callback_data: "approve_#{application_id}" },
            { text: '❌ Отклонить', callback_data: "reject_#{application_id}" }
          ],
          [
            { text: '⏳ Отложить', callback_data: "ignore_#{application_id}" }
          ]
        ]
      )
    end
  end
end 