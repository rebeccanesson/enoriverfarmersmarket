class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :delivery_cycle
  has_many :line_items, :dependent => :destroy
  has_many :orderables, :through => :line_items
  has_many :products, :through => :orderables
  
  validates_presence_of :user_id
  validates_presence_of :delivery_cycle_id
  
  def count_product(prod)
    line_item = self.line_item_for_product(prod)
    (line_item ? line_item.orderables.count : 0)
  end
  
  def line_item_for_product(prod)
    self.line_items.find(:first, :conditions => ["line_items.product_id = ?", prod.id])
  end
  
end
