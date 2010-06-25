class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :delivery_cycle
  has_many :line_items, :dependent => :destroy
  has_many :orderables, :through => :line_items
  has_many :products, :through => :orderables
  
  validates_presence_of :user_id
  validates_presence_of :delivery_cycle_id
  
  acts_as_reportable
  
  def count_product(prod)
    line_item = self.line_item_for_product(prod)
    (line_item ? line_item.orderables.count : 0)
  end
  
  def line_item_for_product(prod)
    self.line_items.find(:first, :conditions => ["line_items.product_id = ?", prod.id])
  end
  
  def subtotal
    self.line_items.inject(0) { |sum, li| sum + li.total_price }
  end
  
  def member_surcharge
    self.subtotal * MEMBER_SURCHARGE
  end
  
  def total 
    self.subtotal + self.member_surcharge
  end 
  
  # added for use in reporting
  def user_name
    self.user.name
  end
  
end
