class AddLogoUrlToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :logo_url, :string
  end

  def self.down
    remove_column :accounts, :logo_url
  end
end
