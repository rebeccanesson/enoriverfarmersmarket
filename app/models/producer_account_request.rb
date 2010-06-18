class ProducerAccountRequest < ActiveRecord::Base
  belongs_to :user
  
  @@valid_statuses = ["Pending", "Approved", "Denied"]
  cattr_accessor :valid_statuses
  
  validates_presence_of :user_id
  validates_inclusion_of :status, :in => @@valid_statuses
  
end
