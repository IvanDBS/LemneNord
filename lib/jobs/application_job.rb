class ApplicationJob
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def self.perform_later(*args)
    perform_async(*args)
  end
end 