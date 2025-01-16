class User < ActiveRecord::Base
  has_many :applications
  has_many :cart_items
  has_many :user_addresses
  has_many :user_phones

  validates :telegram_id, presence: true, uniqueness: true
  validates :language, presence: true, inclusion: { in: ['ru', 'ro'] }

  def default_address
    user_addresses.find_by(is_default: true)
  end

  def default_phone
    user_phones.find_by(is_default: true)
  end

  def add_to_cart(product, quantity)
    cart_items.create!(
      product_code: product[:code],
      product_name: product[:name],
      quantity: quantity,
      price: product[:price]
    )
  end

  def clear_cart
    cart_items.destroy_all
  end

  def cart_total
    cart_items.sum { |item| item.quantity * item.price }
  end
end 