class Admin::HomeController < Admin::AdminController
  
  def index
    @delivery_cycles = DeliveryCycle.find(:all, 
                                          :conditions => ["order_close <= ?", Time.now], 
                                          :order => "order_close DESC")
  end

end