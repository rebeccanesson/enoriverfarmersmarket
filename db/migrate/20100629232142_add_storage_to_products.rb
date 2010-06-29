class AddStorageToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :storage, :string
  end

  def self.down
    remove_column :products, :storage
  end
end
