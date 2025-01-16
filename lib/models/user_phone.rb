class UserPhone < ActiveRecord::Base
  belongs_to :user

  validates :phone_number, presence: true, 
            format: { with: /\A[\d\+\-\(\) ]{10,}\z/ }
  
  before_save :ensure_single_default
  
  private
  
  def ensure_single_default
    if is_default
      UserPhone.where(user_id: user_id)
                .where.not(id: id)
                .update_all(is_default: false)
    end
  end
end 