class LineItem < ActiveRecord::Base
  belongs_to :order
  has_many :orderables
  belongs_to :product
  
  validates_presence_of :order_id, :product_id
  validate :orderables_have_same_product_id
  
  acts_as_reportable
  
  def total_price
    self.product.price_per_unit * self.orderables.count
  end
  
  def item_count
    self.orderables.count
  end
   
  def orderables_have_same_product_id
    prods = self.orderables.collect { |o| o.product }.uniq
    unless prods.empty? or (prods.size == 1 and prods.first == self.product)
      errors.add_to_base "Orderables must be for the same product as their line item"
    end
  end
end
