class SetupBotSchema < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.bigint :telegram_id, null: false
      t.string :language, default: 'ru'
      t.string :status, default: 'active'
      t.string :last_phone
      t.string :last_address
      t.timestamps
    end

    add_index :users, :telegram_id, unique: true

    create_table :applications do |t|
      t.references :user, foreign_key: true
      t.string :status, default: 'draft'
      t.string :product_code
      t.string :product_name
      t.decimal :price
      t.integer :quantity
      t.string :delivery_address
      t.string :phone_number
      t.string :reference_number
      t.string :application_step
      t.boolean :notification_sent, default: false
      t.timestamps
    end

    add_index :applications, :reference_number, unique: true
    add_index :applications, [:user_id, :status]
  end
end 