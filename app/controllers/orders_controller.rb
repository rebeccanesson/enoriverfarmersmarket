class OrdersController < ApplicationController
  before_filter :require_ordering_is_open, :only => [:add_to_cart, :remove_from_cart]
  before_filter :order_is_final, :only => [:invoice]
  
  # GET /orders
  # GET /orders.xml
  def index
    @user = User.find(params[:user_id]) if params[:user_id]
    @delivery_cycle = DeliveryCycle.find(params[:delivery_cycle_id]) if params[:delivery_cycle_id]
    if @user
      @orders = @user.orders
    elsif @delivery_cycle  
      @orders = Order.find(:all, :conditions => ["delivery_cycle_id = ?", @delivery_cycle.id], :order => 'updated_at DESC') 
    else
      @orders = Order.find(:all, :order => "updated_at DESC")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.xml
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.xml
  def new
    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.xml
  def create
    @order = Order.new(params[:order])

    respond_to do |format|
      if @order.save
        flash[:notice] = 'Order was successfully created.'
        format.html { redirect_to(@order) }
        format.xml  { render :xml => @order, :status => :created, :location => @order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.xml
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        flash[:notice] = 'Order was successfully updated.'
        format.html { redirect_to(@order) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.xml
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to(orders_url) }
      format.xml  { head :ok }
    end
  end
  
  def terms
    @order = Order.find(params[:id])
  end
  
  def finalize
    @order = Order.find(params[:id])
    @order.final = true
    if @order.save
      flash[:notice] = 'Your order is now final.'
    else
      flash[:notice] = 'Your order could not be finalized.'
    end
    redirect_to user_order_url(@order.user,@order)
  end    
  
  def invoice
    @order = Order.find(params[:id])
    
    respond_to do |format|
      format.html { 
        @report = UserInvoiceReport.render_html(:user_id=>@order.user.id, :delivery_cycle_id=>@order.delivery_cycle.id)
      }
      format.pdf {
        pdf = UserInvoiceReport.render_pdf(:user_id=>@order.user.id, :delivery_cycle_id=>@order.delivery_cycle.id)
        send_data pdf, :type => "application/pdf", :filename => "#{@order.user.last_name}_invoice.pdf"
      }
    end
  end  
  
  def order_is_final
    @order = Order.find(params[:id])
    unless @order.final
      flash[:notice] = 'Invoices may only be viewed after the order is final'
      redirect_to user_order_url(@order.user,@order)
    end
  end
  
end
