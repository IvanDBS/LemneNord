class AddReferenceNumberIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :applications, :reference_number, unique: true, if_not_exists: true
  end
end 