class AddStatusColumnToOrderables < ActiveRecord::Migration
  def self.up
    add_column :orderables, :status, :string
  end

  def self.down
    remove_column :orderables, :status
  end
end
