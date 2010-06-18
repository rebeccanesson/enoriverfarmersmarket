class ChangeLimitsOnAuthlogicFieldsOnUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :password_salt, :string, :limit => nil
    change_column :users, :crypted_password, :string, :limit => nil
  end

  def self.down
    change_column :users, :password_salt, :string, :limit => 40
    change_column :users, :crypted_password, :string, :limit => 40
  end
end
