class CreateOrderables < ActiveRecord::Migration
  def self.up
    create_table :orderables do |t|
      t.integer :product_id
      t.integer :order_id

      t.timestamps
    end
  end

  def self.down
    drop_table :orderables
  end
end
