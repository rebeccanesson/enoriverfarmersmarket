class Orderable < ActiveRecord::Base
  belongs_to :product
  belongs_to :delivery_cycle
  
  @@statuses = ["Available", "In Cart", "Ordered", "Closed"]
  cattr_accessor :statuses
  
  validates_inclusion_of :status, :in => @@statuses
  validates_presence_of :delivery_cycle_id
  
  named_scope :available, :conditions => "status = 'Available'"
  named_scope :in_cart, :conditions => "status = 'In Cart'"
  named_scope :ordered, :conditions => "status = 'Ordered'"
  named_scope :closed, :conditions => "status = 'Closed'"
  
end
