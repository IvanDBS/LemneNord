# Обработка текстовых сообщений
require_relative '../services/welcome_service'
require_relative '../services/admin_services'
require_relative '../services/order_service'
require_relative '../keyboards/admin_keyboard'
require_relative '../keyboards/user_keyboard'
require_relative '../keyboards/product_keyboard'
require_relative '../messages/messages'

class MessageHandler
  def initialize(bot, message, admin_ids)
    puts "Initializing MessageHandler for user #{message.from.id}"
    @bot = bot
    @message = message
    @admin_ids = admin_ids
    @user = User.find_or_create_by(telegram_id: message.from.id) do |user|
      puts "Creating new user with telegram_id: #{message.from.id}"
      user.language = 'ru'  # Set default language to Russian
      user.status = 'active'
    end
    puts "User found/created: #{@user.inspect}"
  end

  def handle
    puts "Handling message: '#{@message.text}' from user #{@message.from.id}"
    
    # Проверяем новых участников в канале
    if @message.new_chat_members&.any?
      puts "New chat members detected"
      return WelcomeService.handle_new_member(@bot, @message)
    end

    return handle_start if @message.text == '/start'
    return handle_admin_message if @admin_ids.include?(@message.from.id)
    handle_user_message
  end

  private

  def handle_start
    puts "Handling /start command for user #{@message.from.id}"
    @user.update(status: 'active')
    puts "Updated user status to active"
    
    # Проверяем, является ли пользователь админом
    if @admin_ids.include?(@message.from.id)
      puts "User is admin, showing admin menu"
      AdminKeyboard.show_menu(@bot, @message)
    else
      puts "User is not admin, showing language selection"
      @bot.api.send_message(
        chat_id: @message.chat.id,
        text: Messages::MESSAGES['ru'][:welcome],
        reply_markup: UserKeyboard.language_selection
      )
    end
  rescue => e
    puts "Error in handle_start: #{e.message}"
    puts e.backtrace
    raise e
  end

  def handle_admin_message
    case @message.text
    when '/start', '/admin'
      AdminKeyboard.show_menu(@bot, @message)
    when '📊 Статистика'
      AdminServices.show_statistics(@bot, @message)
    when '⏳ Ожидающие'
      AdminServices.show_filtered_orders(@bot, @message, 'pending')
    when '✅ Принятые'
      AdminServices.show_filtered_orders(@bot, @message, 'approved')
    when '❌ Отклоненные'
      AdminServices.show_filtered_orders(@bot, @message, 'rejected')
    when '📢 Рассылка'
      @user.update(status: 'waiting_for_broadcast')
      @bot.api.send_message(
        chat_id: @message.chat.id,
        text: "✍️ Напишите сообщение для рассылки:"
      )
    when '📢 Сообщение в канал'
      AdminServices.broadcast_channel_message(@bot, @message)
    else
      case @user.status
      when 'waiting_for_broadcast'
        handle_broadcast_message
      else
        handle_user_message
      end
    end
  end

  def handle_broadcast_message
    success_count = 0
    error_count = 0
    admin_id = @message.from.id
    
    User.where.not(telegram_id: admin_id).find_each do |user|
      begin
        @bot.api.send_message(
          chat_id: user.telegram_id,
          text: @message.text
        )
        success_count += 1
        sleep(0.1) # Добавляем небольшую задержку
      rescue => e
        error_count += 1
        puts "Broadcast error for user #{user.telegram_id}: #{e.message}"
      end
    end

    # Отправляем статистику и возвращаем админ-меню
    @bot.api.send_message(
      chat_id: @message.chat.id,
      text: "📢 Рассылка завершена\n✅ Отправлено: #{success_count}\n❌ Ошибок: #{error_count}",
      reply_markup: AdminKeyboard.menu
    )

    # Возвращаем пользователя в обычный статус
    @user.update(status: 'active')
  end

  def handle_user_message
    case @message.text
    when '/menu'
      UserKeyboard.show_main_menu(@bot, @message, @user)
    when '🛒 Новый заказ', '🛒 Comandă nouă'
      handle_new_order
    when '📋 Мои заказы', '📋 Comenzile mele'
      handle_my_orders
    when '🌐 Изменить язык', '🌐 Schimbă limba'
      handle_change_language
    else
      OrderService.handle_order_step(@bot, @message, @user)
    end
  end

  def handle_new_order
    puts "Starting new order for user #{@user.id}"
    
    # Обновляем статус пользователя
    @user.update(status: 'filling_application')
    puts "User status updated to filling_application"

    # Показываем список продуктов
    ProductKeyboard.show_products(@bot, @message, @user)
  end

  def handle_my_orders
    # Получаем только завершенные заказы
    orders = @user.applications
                  .where.not(status: 'draft')
                  .where.not(quantity: nil)
                  .where.not(price: nil)
                  .order(created_at: :desc)
                  .limit(10)
    
    if orders.empty?
      @bot.api.send_message(
        chat_id: @message.chat.id,
        text: Messages::MESSAGES[@user.language][:no_orders]
      )
      return
    end

    # Отправляем заказы от старых к новым
    orders.reverse.each do |order|
      OrderService.show_order_details(@bot, @message, order)
      sleep(0.1) # Добавляем небольшую задержку между сообщениями
    end

    # Показываем основное меню после списка заказов
    UserKeyboard.show_main_menu(@bot, @message, @user)
  end

  def handle_change_language
    UserKeyboard.show_language_selection(@bot, @message)
  end
end 