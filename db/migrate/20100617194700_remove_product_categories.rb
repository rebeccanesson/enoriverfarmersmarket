class RemoveProductCategories < ActiveRecord::Migration
  def self.up
    drop_table :product_categories
    add_column :products, :category_id, :integer
  end

  def self.down
    create_table :product_categories do |t|
      t.integer :product_id
      t.integer :category_id

      t.timestamps
    end
    remove_column :products, :category_id
  end
end
