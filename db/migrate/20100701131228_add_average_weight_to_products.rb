class AddAverageWeightToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :min_weight, :float
    add_column :products, :max_weight, :float
  end

  def self.down
    remove_column :products, :min_weight
    remove_column :products, :max_weight
  end
end
