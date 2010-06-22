class ChangeOrderToLineItemInOrderables < ActiveRecord::Migration
  def self.up
    remove_column :orderables, :order_id
    add_column :orderables, :line_item_id, :integer
  end

  def self.down
    add_column :orderables, :order_id, :integer
    remove_column :orderables, :line_item_id
  end
end
