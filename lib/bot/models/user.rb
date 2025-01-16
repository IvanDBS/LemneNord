class User < ActiveRecord::Base
  has_many :applications
  has_many :scheduled_messages

  validates :language, inclusion: { in: ['ru', 'ro'] }
end 