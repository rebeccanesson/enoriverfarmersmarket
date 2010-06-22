class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.integer :order_id
      t.integer :item_count
      t.integer :total

      t.timestamps
    end
  end

  def self.down
    drop_table :line_items
  end
end
