module UserServices
  class << self
    def handle_message(bot, message, user)
      case message.text
      when '/start', '/Start'
        UserKeyboard.show_language_selection(bot, message)
      when '/menu'
        UserKeyboard.show_main_menu(bot, message, user)
      when Messages::MESSAGES[user.language][:new_order]
        handle_new_order(bot, message, user)
      when Messages::MESSAGES[user.language][:my_orders]
        show_orders_history(bot, message, user)
      when Messages::MESSAGES[user.language][:change_language]
        UserKeyboard.show_language_selection(bot, message)
      else
        if user.status == 'filling_application'
          OrderService.handle_order_step(bot, message, user)
        end
      end
    end

    private

    def handle_new_order(bot, message, user)
      return if user.applications.pending.exists?
      user.update(status: 'filling_application')
      ProductKeyboard.show_products(bot, message, user)
    end

    def show_orders_history(bot, message, user)
      orders = user.applications.order(created_at: :desc)
      
      if orders.empty?
        bot.api.send_message(
          chat_id: message.chat.id,
          text: Messages::MESSAGES[user.language][:no_orders]
        )
        return
      end

      orders.each do |order|
        OrderService.show_order_details(bot, message, order)
      end
    end
  end
end 