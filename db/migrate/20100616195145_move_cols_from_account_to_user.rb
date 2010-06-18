class MoveColsFromAccountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :street, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zipcode, :string
    add_column :users, :phone, :string
    add_column :users, :admin, :boolean, :default => false
    
    remove_column :accounts, :first_name
    remove_column :accounts, :last_name
    remove_column :accounts, :producer
    remove_column :accounts, :admin
    
    add_column :accounts, :producer_name, :string
  end

  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :street
    remove_column :users, :city
    remove_column :users, :state
    remove_column :users, :zipcode
    remove_column :users, :phone
    remove_column :users, :admin
    
    add_column :accounts, :first_name, :string
    add_column :accounts, :last_name, :string
    add_column :accounts, :producer, :boolean, :default => false
    add_column :accounts, :admin, :boolean, :default => false
    
    remove_column :accounts, :producer_name
  end
end
