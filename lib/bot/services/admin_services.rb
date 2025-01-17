module AdminServices
  class << self
    def show_statistics(bot, message)
      stats = nil
      RedisConfig::REDIS.with do |redis|
        stats = redis.get("admin_stats")
        if stats.nil?
          stats = {
            total_users: User.count,
            total_orders: Application.count,
            pending_orders: Application.where(status: 'pending').count,
            approved_orders: Application.where(status: 'approved').count,
            rejected_orders: Application.where(status: 'rejected').count
          }
          redis.set("admin_stats", stats.to_json, ex: 300) # expires in 5 minutes
        else
          stats = JSON.parse(stats, symbolize_names: true)
        end
      end

      text = generate_stats_text(stats)
      
      bot.api.send_message(
        chat_id: message.chat.id,
        text: text,
        reply_markup: AdminKeyboard.menu
      )
    rescue => e
      ErrorHandler.handle(bot, e, message.chat.id)
    end

    def show_filtered_orders(bot, message, status)
      orders = Application.where(status: status).order(created_at: :desc).limit(10)
      
      if orders.empty?
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Нет заказов со статусом #{get_status_text(status)}",
          reply_markup: AdminKeyboard.menu
        )
        return
      end

      orders.each do |order|
        OrderService.show_order_details(bot, message, order)
      end
    end

    def approve_order(bot, callback, application_id)
      application = Application.find(application_id)
      application.update(status: 'approved')
      
      # Уведомляем пользователя на его языке
      message = if application.user.language == 'ru'
        "✅ Ваш заказ #{application.reference_number} одобрен!"
      else
        "✅ Comanda dvs. #{application.reference_number} a fost aprobată!"
      end
      
      bot.api.send_message(
        chat_id: application.user.telegram_id,
        text: message
      )
      
      # Обновляем сообщение у админа
      bot.api.edit_message_text(
        chat_id: callback.from.id,
        message_id: callback.message.message_id,
        text: "#{callback.message.text}\n\n✅ Заказ одобрен"
      )
    end

    def reject_order(bot, callback, application_id)
      application = Application.find(application_id)
      application.update(status: 'rejected')
      
      # Уведомляем пользователя на его языке
      message = if application.user.language == 'ru'
        "❌ Ваш заказ #{application.reference_number} отклонен"
      else
        "❌ Comanda dvs. #{application.reference_number} a fost respinsă"
      end
      
      bot.api.send_message(
        chat_id: application.user.telegram_id,
        text: message
      )
      
      # Обновляем сообщение у админа
      bot.api.edit_message_text(
        chat_id: callback.from.id,
        message_id: callback.message.message_id,
        text: "#{callback.message.text}\n\n❌ Заказ отклонен"
      )
    end

    def ignore_order(bot, callback, application_id)
      application = Application.find(application_id)
      application.update(status: 'ignored')
      
      # Обновляем сообщение у админа
      bot.api.edit_message_text(
        chat_id: callback.from.id,
        message_id: callback.message.message_id,
        text: "#{callback.message.text}\n\n⏳ Заказ отложен"
      )
    end

    def broadcast_message(bot, message, text)
      success_count = 0
      fail_count = 0
      
      User.where.not(telegram_id: message.from.id).find_each do |user|
        BroadcastJob.perform_later(user.id, text)
        success_count += 1
      rescue => e
        fail_count += 1
        ErrorHandler.handle(bot, e)
      end

      bot.api.send_message(
        chat_id: message.chat.id,
        text: "📢 Рассылка запущена\n✅ В очереди: #{success_count}\n❌ Ошибок: #{fail_count}",
        reply_markup: AdminKeyboard.menu
      )
    end

    def broadcast_channel_message(bot, message)
      channel_message = <<~MESSAGE
        🌳 Дрова с доставкой по всей Молдове!

        ▫️ Дуб: 1500 лей/складометр
        ▫️ Акация: 1300 лей/складометр

        ✅ Быстрая доставка
        ✅ Качественный сервис
        ✅ Надежный поставщик

        ----

        🌳 Lemne cu livrare în toată Moldova!

        ▫️ Stejar: 1500 lei/ster
        ▫️ Salcâm: 1300 lei/ster

        ✅ Livrare rapidă
        ✅ Serviciu de calitate
        ✅ Furnizor de încredere

        👇 Для заказа нажмите сюда / Pentru comandă click aici 👇
      MESSAGE

      # Создаем кнопку для перехода к боту
      keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(
        inline_keyboard: [
          [
            {
              text: '🤖 Заказать / Comandă',
              url: 'https://t.me/LemneNordLivrare_bot'
            }
          ]
        ]
      )

      begin
        # Отправляем сообщение в канал
        bot.api.send_message(
          chat_id: Config::CHANNEL_ID,
          text: channel_message,
          reply_markup: keyboard,
          parse_mode: 'HTML'
        )

        # Отправляем подтверждение админу
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "✅ Сообщение успешно отправлено в канал",
          reply_markup: AdminKeyboard.menu
        )
      rescue => e
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "❌ Ошибка отправки: #{e.message}",
          reply_markup: AdminKeyboard.menu
        )
      end
    end

    private

    def get_status_text(status)
      case status
      when 'pending' then '⏳ Ожидает'
      when 'approved' then '✅ Одобрен'
      when 'rejected' then '❌ Отклонен'
      when 'ignored' then '⏳ Отложен'
      else status
      end
    end

    def generate_stats_text(stats)
      <<~STATS
        📊 Статистика:

        👥 Всего пользователей: #{stats[:total_users]}
        📦 Всего заказов: #{stats[:total_orders]}
        
        ⏳ Ожидают: #{stats[:pending_orders]}
        ✅ Приняты: #{stats[:approved_orders]}
        ❌ Отклонены: #{stats[:rejected_orders]}
      STATS
    end
  end
end 