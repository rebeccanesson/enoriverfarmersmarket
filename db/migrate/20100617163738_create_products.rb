class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.integer :account_id
      t.string :image_url
      t.string :title
      t.string :description
      t.string :ordering_unit
      t.integer :price_per_unit

      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
