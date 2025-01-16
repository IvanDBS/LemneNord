module WelcomeService
  class << self
    def handle_new_member(bot, message)
      return unless message.new_chat_members

      message.new_chat_members.each do |member|
        # Пропускаем ботов
        next if member.is_bot

        welcome_text = generate_welcome_text(member.first_name)
        
        bot.api.send_message(
          chat_id: message.chat.id,
          text: welcome_text,
          parse_mode: 'HTML',
          reply_markup: generate_bot_button
        )
      end
    end

    private

    def generate_welcome_text(name)
      <<~MESSAGE
        👋 Добро пожаловать, #{name}!

        🌳 Вы присоединились к официальному каналу LemneNord - вашему надежному поставщику дров в Молдове.

        ▫️ У нас вы найдете:
        ✅ Качественные дрова (дуб, акация)
        ✅ Быстрая доставка
        ✅ Выгодные цены

        📱 Для заказа используйте нашего бота
        
        ----

        👋 Bine ați venit, #{name}!

        🌳 V-ați alăturat canalului oficial LemneNord - furnizorul dvs. de încredere de lemne în Moldova.

        ▫️ La noi găsiți:
        ✅ Lemne de calitate (stejar, salcâm)
        ✅ Livrare rapidă
        ✅ Prețuri avantajoase

        📱 Pentru comandă folosiți botul nostru
      MESSAGE
    end

    def generate_bot_button
      Telegram::Bot::Types::InlineKeyboardMarkup.new(
        inline_keyboard: [
          [
            {
              text: '🤖 Перейти к боту / Accesați botul',
              url: 'https://t.me/LemneNordLivrare_bot'
            }
          ]
        ]
      )
    end
  end
end 