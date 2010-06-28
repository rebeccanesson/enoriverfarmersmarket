class Admin::UsersController < Admin::AdminController
  
  def index
    @users = User.find(:all, :order => 'last_name ASC, first_name ASC')
  end

end