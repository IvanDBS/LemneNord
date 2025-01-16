module BackupService
  class << self
    def create_backup
      timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
      backup_path = "backups/bot_#{timestamp}.sqlite3"
      
      FileUtils.mkdir_p('backups')
      FileUtils.cp(Config::DATABASE_CONFIG[:database], backup_path)
      
      # Удаляем старые бэкапы (оставляем последние 7)
      cleanup_old_backups
      
      # Отправляем бэкап админам
      send_backup_to_admins(backup_path)
    end

    private

    def cleanup_old_backups
      backups = Dir['backups/bot_*.sqlite3'].sort
      if backups.size > 7
        backups[0...-7].each { |f| File.delete(f) }
      end
    end

    def send_backup_to_admins(backup_path)
      Config::ADMIN_IDS.each do |admin_id|
        bot.api.send_document(
          chat_id: admin_id,
          document: Faraday::UploadIO.new(backup_path, 'application/x-sqlite3')
        )
      rescue => e
        ErrorHandler.handle(bot, e)
      end
    end
  end
end 