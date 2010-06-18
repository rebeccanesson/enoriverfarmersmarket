class AddAdminUser < ActiveRecord::Migration
  def self.up
    u = User.create(:login => 'admin', 
                    :email => 'foo@example.com', 
                    :password => 'admin', 
                    :password_confirmation => 'admin', 
                    :street => 'foo', 
                    :city => 'foo', 
                    :state => 'AA', 
                    :zipcode => '00000', 
                    :admin => true, 
                    :first_name => 'Admin', 
                    :last_name => 'User')
    u.save! 
  end

  def self.down
    u = User.find_by_login('admin')
    u.destroy
  end
end
