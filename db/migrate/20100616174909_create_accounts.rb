class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :user_id, :null => false
      t.string  :first_name
      t.string  :last_name
      t.string  :street
      t.string  :city
      t.string  :state
      t.string  :zipcode
      t.string  :phone
      t.string  :website_url
      t.boolean :producer, :default => false
      t.boolean :admin, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
