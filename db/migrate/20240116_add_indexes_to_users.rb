class AddIndexesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :telegram_id, unique: true, if_not_exists: true
    add_index :users, :language, if_not_exists: true
  end
end 