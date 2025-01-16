# Обработка нажатий на кнопки
class CallbackHandler
  def initialize(bot, callback, admin_ids)
    @bot = bot
    @callback = callback
    @admin_ids = admin_ids
    @user = User.find_by(telegram_id: callback.from.id)
  end

  def handle
    if @callback.data.start_with?('lang_')
      handle_language_selection
    elsif @callback.data.start_with?('product_')
      handle_product_selection
    elsif @callback.data.start_with?('approve_')
      handle_order_approval
    elsif @callback.data.start_with?('reject_')
      handle_order_rejection
    elsif @callback.data.start_with?('ignore_')
      handle_order_ignore
    end
  end

  private

  def handle_language_selection
    language = @callback.data.split('_').last
    
    # Обновляем язык пользователя без лишних запросов к БД
    @user.update_column(:language, language)

    # Удаляем сообщение с выбором языка
    @bot.api.delete_message(
      chat_id: @callback.message.chat.id,
      message_id: @callback.message.message_id
    )

    # Сразу показываем главное меню
    UserKeyboard.show_main_menu(@bot, @callback.message, @user)
  rescue => e
    puts "Error in language selection: #{e.message}"
  end

  def handle_product_selection
    return unless @user

    # Получаем код продукта после 'product_'
    product_code = @callback.data.gsub('product_', '')
    
    # Отвечаем на callback чтобы убрать "часики"
    begin
      @bot.api.answer_callback_query(callback_query_id: @callback.id)
      
      # Создаем заказ
      OrderService.create_order(@bot, @callback, @user, product_code)
    rescue => e
      ErrorHandler.handle(@bot, e, @callback.from.id)
    end
  end

  def handle_order_approval
    application_id = @callback.data.split('_').last
    AdminServices.approve_order(@bot, @callback, application_id)
  end

  def handle_order_rejection
    application_id = @callback.data.split('_').last
    AdminServices.reject_order(@bot, @callback, application_id)
  end

  def handle_order_ignore
    application_id = @callback.data.split('_').last
    AdminServices.ignore_order(@bot, @callback, application_id)
  end
end 