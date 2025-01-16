class ScheduledMessage < ActiveRecord::Base
  belongs_to :user
  
  validates :message, presence: true
  validates :delay_minutes, numericality: { greater_than: 0 }
  
  scope :pending, -> { where(sent: false) }
end 