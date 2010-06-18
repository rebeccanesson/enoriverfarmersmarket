class AddDescriptionToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :description, :text
  end

  def self.down
    remove_column :accounts, :description
  end
end
