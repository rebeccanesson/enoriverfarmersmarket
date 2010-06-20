class CreateDeliveryCycles < ActiveRecord::Migration
  def self.up
    create_table :delivery_cycles do |t|
      t.datetime :edit_open
      t.datetime :edit_close
      t.datetime :order_open
      t.datetime :order_close
      t.datetime :delivery_open
      t.datetime :delivery_close

      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_cycles
  end
end
