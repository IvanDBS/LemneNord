module OrderService
  class << self
    def create_order(bot, callback, user, product_code)
      product = find_product(user.language, product_code)
      return unless product

      begin
        # Отвечаем на callback чтобы убрать "часики"
        bot.api.answer_callback_query(callback_query_id: callback.id)

        # Создаем заказ без валидации quantity
        application = user.applications.new(
          status: 'draft',
          product_code: product[:code],
          product_name: product[:name],
          application_step: 'quantity',
          price: product[:price]
        )
        
        # Пропускаем валидации при создании черновика
        application.save(validate: false)

        # Отправляем информацию о продукте
        product_info = [
          product[:name],
          product[:description].gsub('\\n', "\n")
        ].join("\n\n")
        
        bot.api.send_message(
          chat_id: callback.from.id,
          text: "#{product_info}\n\n#{Messages::MESSAGES[user.language][:enter_quantity]}"
        )
      rescue => e
        ErrorHandler.handle(bot, e, callback.from.id)
      end
    end

    def show_order_details(bot, message, order)
      begin
        # Проверяем наличие необходимых данных
        return unless order.quantity && order.price

        total_price = order.quantity * order.price
        
        # Получаем название товара на текущем языке пользователя
        current_product = find_product(order.user.language, order.product_code)
        product_name = current_product ? current_product[:name] : order.product_name
        
        text = if order.user.language == 'ru'
          <<~TEXT
            📦 Заказ #{order.reference_number}
            
            🌳 Товар: #{product_name}
            📝 Количество: #{order.quantity} #{TextHelper.pluralize_ster(order.quantity)}
            💰 Цена за складометр: #{order.price} лей
            💵 Общая стоимость: #{total_price} лей
            
            📍 Адрес: #{order.delivery_address}
            📱 Телефон: #{order.phone_number}
            
            📅 Дата: #{order.created_at.in_time_zone('Europe/Chisinau').strftime("%d.%m.%Y %H:%M")}
            📊 Статус: #{get_status_text(order.status)}
          TEXT
        else
          <<~TEXT
            📦 Comandă #{order.reference_number}
            
            🌳 Produs: #{product_name}
            📝 Cantitate: #{order.quantity} #{TextHelper.pluralize_ster_ro(order.quantity)}
            💰 Preț per ster: #{order.price} lei
            💵 Cost total: #{total_price} lei
            
            📍 Adresa: #{order.delivery_address}
            📱 Telefon: #{order.phone_number}
            
            📅 Data: #{order.created_at.in_time_zone('Europe/Chisinau').strftime("%d.%m.%Y %H:%M")}
            📊 Status: #{get_status_text(order.status)}
          TEXT
        end

        bot.api.send_message(
          chat_id: message.chat.id,
          text: text,
          reply_markup: is_admin?(message) && order.status == 'pending' ? AdminKeyboard.application_buttons(order.id) : nil
        )
      rescue => e
        ErrorHandler.handle(bot, e, message.chat.id)
      end
    end

    def get_status_text(status)
      if @user&.language == 'ru'
        case status
        when 'pending' then '⏳ Ожидает'
        when 'approved' then '✅ Одобрен'
        when 'rejected' then '❌ Отклонен'
        when 'ignored' then '⏳ Отложен'
        else status
        end
      else
        case status
        when 'pending' then '⏳ În așteptare'
        when 'approved' then '✅ Aprobată'
        when 'rejected' then '❌ Respinsă'
        when 'ignored' then '⏳ Amânată'
        else status
        end
      end
    end

    def handle_order_step(bot, message, user)
      # Используем блокировку чтобы избежать конфликтов
      Application.transaction do
        application = user.applications.lock.where(status: ['draft', 'pending']).last
        return unless application

        case application.application_step
        when 'quantity'
          handle_quantity(bot, message, application)
        when 'address'
          handle_address(bot, message, application)
        when 'phone'
          handle_phone(bot, message, application)
        end
      end
    rescue => e
      ErrorHandler.handle(bot, e, message.chat.id)
    end

    def handle_phone(bot, message, application)
      if message.text.start_with?('📱 Использовать сохраненный номер', '📱 Folosiți numărul salvat')
        if application.user.last_phone.present?
          # Очищаем телефон от предыдущих накоплений
          clean_phone = application.user.last_phone.gsub(/[^\d\+]/, '').strip
          
          # Проверяем валидность сохраненного номера
          unless clean_phone.match?(/^[\d\+]{10,}$/)
            bot.api.send_message(
              chat_id: message.chat.id,
              text: application.user.language == 'ru' ? 
                "Сохраненный номер некорректен. Пожалуйста, введите новый номер телефона" :
                "Numărul salvat nu este valid. Vă rugăm să introduceți un număr nou"
            )
            return
          end
          
          complete_order(bot, message, application, clean_phone)
          return
        end
      end

      # Очищаем введенный телефон от всего кроме цифр и +
      clean_phone = message.text.gsub(/[^\d\+]/, '').strip
      
      unless clean_phone.match?(/^[\d\+]{10,}$/)
        bot.api.send_message(
          chat_id: message.chat.id,
          text: application.user.language == 'ru' ? 
            "Пожалуйста, введите корректный номер телефона" :
            "Vă rugăm să introduceți un număr de telefon valid"
        )
        return
      end

      application.user.update(last_phone: clean_phone)
      complete_order(bot, message, application, clean_phone)
    end

    def handle_address(bot, message, application)
      if message.text.start_with?('📍 Использовать сохраненный адрес', '📍 Folosiți adresa salvată')
        if application.user.last_address.present?
          # Очищаем адрес от предыдущих накоплений
          clean_address = application.user.last_address.gsub(/\(.*\)/, '').strip
          
          # Проверяем длину адреса
          if clean_address.length < 5
            bot.api.send_message(
              chat_id: message.chat.id,
              text: application.user.language == 'ru' ? 
                "Сохраненный адрес слишком короткий. Пожалуйста, введите новый адрес" :
                "Adresa salvată este prea scurtă. Vă rugăm să introduceți o adresă nouă"
            )
            return
          end
          
          application.update(
            delivery_address: clean_address,
            application_step: 'phone'
          )
          
          bot.api.send_message(
            chat_id: message.chat.id,
            text: Messages::MESSAGES[application.user.language][:enter_phone],
            reply_markup: saved_phone_keyboard(application.user)
          )
          return
        end
      end

      if message.text.length < 5
        bot.api.send_message(
          chat_id: message.chat.id,
          text: application.user.language == 'ru' ? 
            "Пожалуйста, введите корректный адрес" :
            "Vă rugăm să introduceți o adresă validă"
        )
        return
      end

      # Очищаем введенный адрес
      clean_address = message.text.gsub(/\(.*\)/, '').strip
      
      application.user.update(last_address: clean_address)
      application.update(
        delivery_address: clean_address,
        application_step: 'phone'
      )

      bot.api.send_message(
        chat_id: message.chat.id,
        text: Messages::MESSAGES[application.user.language][:enter_phone],
        reply_markup: saved_phone_keyboard(application.user)
      )
    end

    private

    def find_product(language, code)
      Application::AVAILABLE_PRODUCTS[language].find { |p| p[:code] == code }
    end

    def create_application(user, product)
      user.applications.create!(
        status: 'draft',
        product_code: product[:code],
        product_name: product[:name],
        application_step: 'quantity',
        price: product[:price]
      )
    end

    def send_product_info(bot, callback, user, product)
      product_info = [
        product[:name],
        product[:description].gsub('\\n', "\n")
      ].join("\n\n")
      
      bot.api.send_message(
        chat_id: callback.from.id,
        text: "#{product_info}\n\n#{Messages::MESSAGES[user.language][:enter_quantity]}"
      )
    end

    def handle_quantity(bot, message, application)
      quantity = message.text.to_i
      if quantity <= 0
        bot.api.send_message(
          chat_id: message.chat.id,
          text: application.user.language == 'ru' ? 
            "Пожалуйста, введите корректное количество (больше 0)" :
            "Vă rugăm să introduceți o cantitate validă (mai mare de 0)"
        )
        return
      end

      application.update(quantity: quantity)
      
      total = quantity * application.price
      bot.api.send_message(
        chat_id: message.chat.id,
        text: Messages::MESSAGES[application.user.language][:price_info] % { 
          price: application.price,
          total: total
        }
      )

      application.update(application_step: 'address')
      
      # Показываем сообщение для ввода адреса
      bot.api.send_message(
        chat_id: message.chat.id,
        text: Messages::MESSAGES[application.user.language][:enter_address],
        reply_markup: saved_address_keyboard(application.user)
      )
    end

    def generate_reference_number
      "LN-#{Time.now.strftime('%Y%m%d')}-#{rand(1000..9999)}"
    end

    def notify_about_order_creation(bot, message, application)
      # Отправляем подтверждение клиенту
      bot.api.send_message(
        chat_id: message.chat.id,
        text: Messages::MESSAGES[application.user.language][:application_submitted],
        reply_markup: UserKeyboard.menu(application.user.language)
      )

      # Уведомляем админов
      NotificationService.notify_admins(bot, application)
    end

    def show_order_confirmation(bot, message, application)
      # Отправляем сообщение с благодарностью
      bot.api.send_message(
        chat_id: message.chat.id,
        text: Messages::MESSAGES[application.user.language][:application_submitted],
        reply_markup: UserKeyboard.menu(application.user.language) # Добавляем клавиатуру меню
      )
    end

    def complete_order(bot, message, application, phone)
      reference_number = generate_reference_number
      
      application.update!(
        phone_number: phone,
        status: 'pending',
        application_step: 'completed',
        reference_number: reference_number
      )

      notify_about_order_creation(bot, message, application)
    end

    def saved_address_keyboard(user)
      return nil unless user&.last_address.present?
      
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: [
          [{ text: user.language == 'ru' ? 
            "📍 Использовать сохраненный адрес (#{user.last_address})" : 
            "📍 Folosiți adresa salvată (#{user.last_address})" 
          }]
        ],
        resize_keyboard: true,
        one_time_keyboard: true
      )
    end

    def saved_phone_keyboard(user)
      return nil unless user&.last_phone.present?
      
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: [
          [{ text: user.language == 'ru' ? 
            "📱 Использовать сохраненный номер (#{user.last_phone})" : 
            "📱 Folosiți numărul salvat (#{user.last_phone})" 
          }]
        ],
        resize_keyboard: true,
        one_time_keyboard: true
      )
    end

    def is_admin?(message)
      Config::ADMIN_IDS.include?(message.from.id)
    end
  end
end 