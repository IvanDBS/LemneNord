class AddIndexesToApplications < ActiveRecord::Migration[7.0]
  def change
    add_index :applications, :user_id, if_not_exists: true
    add_index :applications, :status, if_not_exists: true
    add_index :applications, :created_at, if_not_exists: true
  end
end 