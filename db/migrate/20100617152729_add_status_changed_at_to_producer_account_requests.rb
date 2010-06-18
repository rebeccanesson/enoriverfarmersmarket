class AddStatusChangedAtToProducerAccountRequests < ActiveRecord::Migration
  def self.up
    add_column :producer_account_requests, :status_changed_at, :datetime
  end

  def self.down
    remove_column :producer_account_requests, :status_changed_at
  end
end
