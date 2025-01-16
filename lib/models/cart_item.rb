class CartItem < ActiveRecord::Base
  belongs_to :user
  
  validates :quantity, presence: true, 
            numericality: { greater_than: 0 }
  validates :price, presence: true,
            numericality: { greater_than: 0 }
  validates :product_code, presence: true
  validates :product_name, presence: true
end 