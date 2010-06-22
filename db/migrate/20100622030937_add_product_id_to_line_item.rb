class AddProductIdToLineItem < ActiveRecord::Migration
  def self.up
    add_column :line_items, :product_id, :integer
  end

  def self.down
    remove_column :line_items, :product_id
  end
end
