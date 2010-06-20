class AddDeliveryCycleToOrderables < ActiveRecord::Migration
  def self.up
    add_column :orderables, :delivery_cycle_id, :integer
  end

  def self.down
    remove_column :orderables, :delivery_cycle_id
  end
end
