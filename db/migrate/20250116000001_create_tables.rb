class CreateTables < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.bigint :telegram_id, null: false
      t.string :username
      t.string :language, default: 'ru'
      t.string :status, default: 'active'
      t.string :last_phone
      t.string :last_address
      t.timestamps
      
      t.index :telegram_id, unique: true
    end

    create_table :applications do |t|
      t.belongs_to :user
      t.string :status
      t.string :product_code
      t.string :product_name
      t.integer :quantity
      t.decimal :price, precision: 10, scale: 2
      t.string :delivery_address
      t.string :phone_number
      t.string :application_step
      t.string :reference_number
      t.timestamps
      
      t.index :reference_number, unique: true
    end
  end
end 