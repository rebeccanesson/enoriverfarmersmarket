class User < ActiveRecord::Base
  acts_as_authentic
  
  has_many :owned_accounts, :class_name => 'Account', :dependent => :destroy
  has_many :account_memberships, :dependent => :destroy
  has_many :managed_account_memberships, :through => :account_memberships, :source => :account
  has_many :producer_account_requests, :dependent => :destroy, :order => 'created_at DESC'
  has_many :orders, :order => 'created_at DESC'
  
  validates_presence_of :first_name, :last_name, :phone
  
  acts_as_reportable
  
  def name
    "#{self.first_name} #{self.last_name}"
  end
  
  def address
    "#{self.street}, #{self.city}, #{self.state} #{self.zipcode}"
  end
  
  def request_producer_account
    ProducerAccountRequest.create(:user_id => self.id, :status => 'Pending', :status_changed_at => Time.now)
  end
  
  def managed_accounts
    owned_accounts + managed_account_memberships
  end
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Notifier.deliver_password_reset_instructions(self)  
  end
  
  def current_order
    delivery_cycle = DeliveryCycle.current
    return unless delivery_cycle
    Order.find(:first, :conditions => ["user_id = ? and delivery_cycle_id = ?", self.id, delivery_cycle.id])
  end
  
  def is_producer
    self.managed_accounts.size > 0
  end
  
  def phone_string
    if self.phone.blank? 
      'none'
    elsif self.phone_two.blank? 
      self.phone
    elsif self.phone_three.blank? 
      "#{self.phone} and #{self.phone_two}"
    else
      "#{self.phone}, #{self.phone_two} and #{self.phone_three}"
    end 
  end
  
  def self.producers
    User.all.reject { |u| u.managed_accounts.size == 0 }
  end
    
end
