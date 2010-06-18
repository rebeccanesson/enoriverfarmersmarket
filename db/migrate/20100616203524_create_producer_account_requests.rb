class CreateProducerAccountRequests < ActiveRecord::Migration
  def self.up
    create_table :producer_account_requests do |t|
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :producer_account_requests
  end
end
