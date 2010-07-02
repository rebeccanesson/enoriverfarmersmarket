class AddProfileImageToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :profile_image, :string
  end

  def self.down
    add_column :accounts, :profile_image
  end
end
