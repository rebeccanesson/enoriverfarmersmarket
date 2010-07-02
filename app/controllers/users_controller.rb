class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update, :add_to_cart, :remove_from_cart]
  before_filter :require_ordering_is_open, :only => [:add_to_cart, :remove_from_cart]
  before_filter :require_order_not_final, :only => [:add_to_cart, :remove_from_cart]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_to user_url(@user)
    else
      render :action => :new
    end
  end
  
  def show
    @user = User.find(params[:id])
    @delivery_cycles = DeliveryCycle.find(:all, 
                                          :conditions => ["order_close <= ?", Time.now], 
                                          :order => "order_close DESC")
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id]) # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to user_url(@user)
    else
      render :action => :edit
    end
  end
  
  def request_producer_account
    @user = User.find(params[:id])
    if @user.request_producer_account
      flash[:notice] = "The administrators have been notified of your request."
      redirect_to user_url(@user)
    else
      flash[:notice] = "There was a problem making your request. Please contact the administrator."
      redirect_to user_url(@user)
    end
  end
  
  def add_to_cart
    success = false
    @user = User.find(params[:id])
    @product = Product.find(params[:product_id])
    @orderable = @product.available_orderables_in_cycle(@current_delivery_cycle).first
    if @orderable
      @order = @user.current_order
      if !@order
        @order = Order.create(:user_id => @user.id, :delivery_cycle => @current_delivery_cycle)
      end
      if @order
        @line_item = @order.line_item_for_product(@product) || LineItem.create(:order_id => @order.id, :product_id => @product.id)
        if @line_item.save
          @orderable.update_attributes(:status => 'In Cart', :line_item_id => @line_item.id)
          if @orderable.save
            success = true
          end
        end
      end
    end
    respond_to do |format|
      if success
        format.html { 
          flash[:notice] = "The item has been added to your cart."
          redirect_to products_url
        }
      else
        format.html { 
          flash[:notice] = "The item could not be added to the cart."
          redirect_to products_url 
        }
      end
    end
  end
  
  def remove_from_cart
    result = false
    @user = User.find(params[:id])
    @line_item = LineItem.find(params[:line_item_id])
    if @line_item and @line_item.orderables.size > 0
      @orderable = @line_item.orderables.first
      @orderable.update_attributes(:status => 'Available', :line_item_id => nil)
      result = @orderable.save
      if @line_item.orderables.size == 0
        @line_item.destroy
      end
    end
    respond_to do |format|
      if result
        format.html { 
          flash[:notice] = "Item removed from cart."
          redirect_to user_order_url(@user, @user.current_order)
        }
      else
        format.html { 
          flash[:notice] = "Could not remove item from cart."
          redirect_to user_order_url(@user, @user.current_order)
        }
      end
    end
  end
  
  def remove_all_from_cart
    result = false
    @user = User.find(params[:id])
    @line_item = LineItem.find(params[:line_item_id])
    if @line_item and @line_item.orderables.size > 0
      @line_item.orderables.each do |orderable|
        orderable.update_attributes(:status => 'Available', :line_item_id => nil)
        result = result and orderable.save
      end
      @line_item.destroy 
    end
    respond_to do |format|
      if result
        format.html { 
          flash[:notice] = "The items have been removed from your cart."
          redirect_to user_order_url(@user, @user.current_order)
        }
      else 
        format.html { 
          flash[:notice] = "There was an error removing items from your cart."
          redirect_to user_order_url(@user,@user.current_order)
        }
      end
    end
  end
  
  def require_order_not_final
    @user = User.find(params[:id])
    @order = @user.current_order
    if @order and @order.final
      flash[:notice] = 'Invoices may only be viewed before the order is final.'
      redirect_to user_order_url(@order.user,@order)
    end
  end
  
  def category_request 
    @user = User.find(params[:id])
    @account = Account.find(params[:account_id])
    @product = Product.find(params[:product_id]) if params[:product_id]
  end
  
  
  def send_category_request
    text = params[:text]
    requesting_user = User.find(params[:id])
    @account = Account.find(params[:account_id])
    @product = Product.find(params[:product_id]) unless params[:product_id].blank?
    User.admins.each do |admin_user|
      UserMailer.deliver_category_request(admin_user,requesting_user,text)
    end
    flash[:notice] = "The adminstrator has been notified of your request."
    if @product
      redirect_to edit_account_product_url(@account,@product)
    else
      redirect_to new_account_product_url(@account)
    end
  end
  
end
