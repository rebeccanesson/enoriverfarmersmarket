class Admin::ProducerAccountRequestsController < Admin::AdminController
  
  def index
    @producer_account_requests = ProducerAccountRequest.find(:all, :order => "created_at DESC")
  end
  
  def approve
  end
  
  def deny
    @par = ProducerAccountRequest.find(params[:id])
    @par.update_attributes(:status => "Denied", :status_changed_at => Time.now)
    if @par.save
      flash[:notice] = "Producer account request has been denied.  The account holder will be notified on login."
      redirect_to producer_account_requests_url 
    else 
      flash[:notice] = "There was an error denying the request."
      redirect_to producer_account_requests_url
    end
  end
  
  def approve
    @par = ProducerAccountRequest.find(params[:id])
    @account = Account.new(:user_id => @par.user_id)
    ProducerAccountRequest.transaction do 
      @account.save
      @par.update_attributes(:status => "Approved", :status_changed_at => Time.now)
      @par.save
    end
    
    if @account.id 
      flash[:notice] = "Producer account request has been approved.  The account holder will be notified on login."
    else
      flash[:notice] = "An error has occurred approving this account request."
    end
    redirect_to producer_account_requests_url
  end
  
  def destroy
    @par = ProducerAccountRequest.find(params[:id])
    @par.destroy

    respond_to do |format|
      format.html { redirect_to(producer_account_requests_url) }
      format.xml  { head :ok }
    end
  end

end