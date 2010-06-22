class RemoveItemCountAndTotalFromLineItem < ActiveRecord::Migration
  def self.up
    remove_column :line_items, :item_count
    remove_column :line_items, :total
  end

  def self.down
    add_column :line_items, :item_count, :integer
    add_column :line_items, :total, :integer
  end
end
