class AddPickupOpenAndPickupCloseToDeliveryCycles < ActiveRecord::Migration
  def self.up
    add_column :delivery_cycles, :pickup_open, :datetime
    add_column :delivery_cycles, :pickup_close, :datetime
  end

  def self.down
    remove_column :delivery_cycles, :pickup_open
    remove_column :delivery_cycles, :pickup_close
  end
end
