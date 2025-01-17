class AddCartAndUserDetails < ActiveRecord::Migration[7.0]
  def change
    # Сохраненные адреса пользователей
    create_table :user_addresses do |t|
      t.belongs_to :user
      t.string :address
      t.boolean :is_default, default: false
      t.timestamps
    end

    # Сохраненные телефоны
    create_table :user_phones do |t|
      t.belongs_to :user
      t.string :phone_number
      t.boolean :is_default, default: false
      t.timestamps
    end

    # Корзина
    create_table :cart_items do |t|
      t.belongs_to :user
      t.string :product_code
      t.string :product_name
      t.integer :quantity
      t.decimal :price, precision: 10, scale: 2
      t.timestamps
    end
  end
end 