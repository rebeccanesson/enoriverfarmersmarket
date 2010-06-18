class Orderable < ActiveRecord::Base
  belongs_to :product
  
  @@statuses = ["Available", "In Cart", "Ordered", "Closed"]
  cattr_accessor :statuses
  
  validates_inclusion_of :status, :in => @@statuses
end
