class AddForemanToBookings < ActiveRecord::Migration[5.1]
  def change
    add_column :bookings, :foreman, :references
  end
end
