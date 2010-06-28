class Admin::ProducersController < Admin::AdminController
  
  def index
    @accounts = Account.find(:all, :order => "producer_name ASC")
  end

end