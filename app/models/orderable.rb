class Orderable < ActiveRecord::Base
  belongs_to :product
  belongs_to :delivery_cycle
  belongs_to :line_item
  has_one :order, :through => :line_item
  has_one :seller, :class_name => 'User', :through => :product
  has_one :purchaser, :class_name => 'User', :through => :order
  
  @@statuses = ["Available", "In Cart", "Ordered", "Closed"]
  cattr_accessor :statuses
  
  validates_inclusion_of :status, :in => @@statuses
  validates_presence_of :delivery_cycle_id
  
  named_scope :available, :conditions => "status = 'Available'"
  named_scope :in_cart, :conditions => "status = 'In Cart'"
  named_scope :ordered, :conditions => "status = 'Ordered'"
  named_scope :closed, :conditions => "status = 'Closed'"
  
  def add_to_cart(override=false)
    if self.status == 'Available' or override
      self.status = 'In Cart'
    end
  end
  
end
