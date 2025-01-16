module NotificationService
  class << self
    def notify_admins(bot, application)
      Config::ADMIN_IDS.each do |admin_id|
        begin
          bot.api.send_message(
            chat_id: admin_id,
            text: generate_admin_notification(application),
            reply_markup: AdminKeyboard.application_buttons(application.id),
            parse_mode: 'HTML'
          )
        rescue => e
          ErrorHandler.handle(bot, e)
          next
        end
      end
    end

    private

    def generate_admin_notification(application)
      total = application.quantity * application.price
      created_at = application.created_at.in_time_zone('Europe/Chisinau')

      <<~TEXT
        🆕 <b>Новый заказ #{application.reference_number}</b>

        👤 Клиент: #{application.user.telegram_id}
        
        🌳 Товар: #{application.product_name}
        📝 Количество: #{application.quantity} складометров
        💰 Цена: #{application.price} лей
        💵 Сумма: #{total} лей
        
        📍 Адрес: #{application.delivery_address}
        📱 Телефон: #{application.phone_number}
        
        📅 Дата: #{created_at.strftime("%d.%m.%Y %H:%M")}
      TEXT
    end
  end
end 