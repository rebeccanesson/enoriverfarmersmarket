class Admin::UsersController < Admin::AdminController
  
  def index
    @users = User.find(:all, :order => 'last_name ASC, first_name ASC')
  end
  
  def compose_users_email 
  end
  
  def send_users_email
    text = params[:text]
    User.all.each do |user|
      UserMailer.deliver_general_email(user,text)
    end
    redirect_to '/admin'
  end
  
  def compose_producers_email
  end
  
  def send_producers_email
    text = params[:text]
    User.producers.each do |user|
      UserMailer.deliver_general_email(user,text)
    end
    redirect_to '/admin'
  end
  
  def make_admin
    @user = User.find(params[:id])
    @user.admin = true
    if @user.save
      flash[:notice] = "#{@user.name} now has administrator privileges."
      redirect_to admin_users_path
    else 
      flash[:notice] = "Could not give #{@user.name} adminstrator privileges.  There may be some missing data in the user account."
      redirect_to admin_users_path
    end
  end
  
  def remove_admin
    @user = User.find(params[:id])
    logger.debug("#{@user.name} has id #{@user.id}")
    @user.admin = false
    if @user.save
      flash[:notice] = "#{@user.name} no longer has administrator privileges."
      redirect_to admin_users_path
    else 
      flash[:notice] = "Could not remove #{@user.name}'s adminstrator privileges.  There may be some missing data in the user account."
      redirect_to admin_users_path
    end
  end
end