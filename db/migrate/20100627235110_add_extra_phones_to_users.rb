class AddExtraPhonesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :phone_two, :string
    add_column :users, :phone_three, :string
  end

  def self.down
    remove_column :users, :phone_two
    remove_column :users, :phone_three
  end
end
