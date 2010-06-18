class AddImageUrlToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :image_url, :string
  end

  def self.down
    remove_column :categories, :image_url
  end
end
