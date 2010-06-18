class AccountsController < ApplicationController
  before_filter :require_user
  before_filter :require_admin, :only => :index
  before_filter :load_account, :only => [:show,:edit,:update,:destroy]
  before_filter :require_owner_or_admin, :only => [:edit,:update,:destroy]
  
  # GET /accounts
  # GET /accounts.xml
  def index
    @accounts = Account.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = Account.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        flash[:notice] = 'Account was successfully created.'
        format.html { redirect_to(@account) }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = 'Account was successfully updated.'
        format.html { redirect_to(@account) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
  
  def add_member
    @account = Account.find(params[:id])
    if params[:user] and params[:user][:login]
      @user = User.find_by_login(params[:user][:login])
    end
    if @user
      am = AccountMembership.create(:user => @user, :account => @account)
    end
    if am.save
      flash[:notice] = "#{@user.login} added as a manager of #{@account.producer_name}"
    else
      flash[:notice] = "Failed to add #{@user.login} as a manager of #{@account.producer_name}"
    end
    redirect_to account_url(@account)
  end 
  
  def remove_member
    @account = Account.find(params[:id])
    if params[:user_id]
      @am = AccountMembership.find(:first, :conditions => {:account_id => @account.id, :user_id => params[:user_id]})
    end
    if @am
      @am.destroy
      flash[:notice] = "Account manager removed"
    else 
      flash[:notice] = "Error removing account manager"
    end
    redirect_to account_url(@account)
  end
      
    
  
  def load_account
    @account = Account.find(params[:id])
    redirect_to new_user_session_path unless @account
  end
  
  def require_owner_or_admin
    unless current_user and (current_user.managed_accounts.include?(@account) or current_user.admin)
      flash[:notice] = "You must own the account or be an administrator to perform this action."
      redirect_to account_path(@account)
    end
  end
end
