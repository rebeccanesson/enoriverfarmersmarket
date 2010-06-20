class Account < ActiveRecord::Base
  
  belongs_to :creator, :class_name => 'User', :foreign_key => 'user_id'
  has_many :account_memberships, :dependent => :destroy
  has_many :account_managers, :through => :account_memberships, :source => :user
  has_many :products, :dependent => :destroy
  
  validates_uniqueness_of :producer_name, :on => :update
  validates_presence_of :producer_name, :city, :state, :zipcode, :on => :update
  validates_presence_of :user_id
  
  def managers 
    [self.creator] + self.account_managers
  end
  
  def name
    self.producer_name
  end 
  
end
