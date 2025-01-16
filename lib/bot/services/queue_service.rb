module QueueService
  class << self
    def process_notifications
      Application.where(status: 'pending', notification_sent: false)
                .find_each do |application|
        begin
          NotificationService.notify_admins(bot, application)
          application.update(notification_sent: true)
        rescue => e
          ErrorHandler.handle(bot, e)
        end
      end
    end

    def cleanup_old_drafts
      # Удаляем черновики старше 24 часов
      Application.where(status: 'draft')
                .where('created_at < ?', 24.hours.ago)
                .delete_all
    end

    def process_delayed_messages
      DelayedMessage.where('send_at <= ?', Time.now)
                   .find_each do |message|
        begin
          bot.api.send_message(
            chat_id: message.chat_id,
            text: message.text
          )
          message.destroy
        rescue => e
          ErrorHandler.handle(bot, e)
        end
      end
    end
  end
end 