module ProductKeyboard
  def self.show_products(bot, message, user)
    puts "\nShowing products:"
    puts "User: #{user.id} (#{user.telegram_id})"
    puts "Language: #{user.language}"
    
    products = Application::AVAILABLE_PRODUCTS[user.language]
    puts "Available products: #{products.map{|p| p[:code]}.join(', ')}"
    
    keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: products.map do |product|
        button = { 
          text: "#{product[:name]} - #{product[:price]} #{user.language == 'ru' ? 'лей' : 'lei'}", 
          callback_data: "product_#{product[:code]}"
        }
        puts "Creating button: #{button.inspect}"
        [button]
      end
    )

    begin
      bot.api.send_message(
        chat_id: message.chat.id,
        text: Messages::MESSAGES[user.language][:select_product],
        reply_markup: keyboard
      )
      puts "Products menu sent"
    rescue => e
      puts "Error showing products: #{e.message}"
      puts e.backtrace
    end
  end
end 