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

end