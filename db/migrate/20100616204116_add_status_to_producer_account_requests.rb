class AddStatusToProducerAccountRequests < ActiveRecord::Migration
  def self.up
    add_column :producer_account_requests, :status, :string
  end

  def self.down
    add_column :producer_account_requests, :status
  end
end
