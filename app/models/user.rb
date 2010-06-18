class User < ActiveRecord::Base
  acts_as_authentic
  
  has_many :owned_accounts, :class_name => 'Account', :dependent => :destroy
  has_many :account_memberships, :dependent => :destroy
  has_many :managed_account_memberships, :through => :account_memberships, :source => :account
  has_many :producer_account_requests, :dependent => :destroy, :order => 'created_at DESC'
  
  validates_presence_of :first_name, :last_name, :street, :city, :state, :zipcode
  
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

end
