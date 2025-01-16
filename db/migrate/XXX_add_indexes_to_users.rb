class AddIndexesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :telegram_id, unique: true
    add_index :users, :language
  end
end 