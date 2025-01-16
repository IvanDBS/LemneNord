class UserAddress < ActiveRecord::Base
  belongs_to :user

  validates :address, presence: true, length: { minimum: 5 }
  
  before_save :ensure_single_default
  
  private
  
  def ensure_single_default
    if is_default
      UserAddress.where(user_id: user_id)
                 .where.not(id: id)
                 .update_all(is_default: false)
    end
  end
end 