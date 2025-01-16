module UserKeyboard
  class << self
    def language_selection
      Telegram::Bot::Types::InlineKeyboardMarkup.new(
        inline_keyboard: [
          [
            { text: '🇷🇺 Русский', callback_data: 'lang_ru' },
            { text: '🇷🇴 Română', callback_data: 'lang_ro' }
          ]
        ]
      )
    end

    def menu(language)
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: [
          [
            { text: language == 'ru' ? '🛒 Новый заказ' : '🛒 Comandă nouă' }
          ],
          [
            { text: language == 'ru' ? '📋 Мои заказы' : '📋 Comenzile mele' },
            { text: language == 'ru' ? '🌐 Изменить язык' : '🌐 Schimbă limba' }
          ]
        ],
        resize_keyboard: true
      )
    end

    def show_main_menu(bot, message, user)
      bot.api.send_message(
        chat_id: message.chat.id,
        text: Messages::MESSAGES[user.language][:menu],
        reply_markup: menu(user.language)
      )
    end

    def show_language_selection(bot, message)
      bot.api.send_message(
        chat_id: message.chat.id,
        text: Messages::MESSAGES['ru'][:welcome],
        reply_markup: language_selection
      )
    end
  end
end 