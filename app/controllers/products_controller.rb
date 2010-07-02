class ProductsController < ApplicationController
  # GET /products
  # GET /products.xml
  
  before_filter :load_product, :only => [:show, :edit, :update, :destroy, :make_orderable, :remove_orderable, :add_to_cart]
  before_filter :load_account, :except => [:index, :show, :add_to_cart]
  before_filter :is_owner_or_admin, :only => [:edit, :update, :destroy]
  before_filter :load_sidebar_variables, :only => [:index]
  before_filter :ordering_and_delivery_closed, :only => [:edit, :update, :destroy]
  before_filter :can_make_orderable, :only => [:make_orderable, :remove_orderable]
  
  def index
    page = params[:page] if params[:page]
    page = 1 unless page
    @search = Product.search(params[:search])
    @products = @search.all.uniq
    @facets = Product.facet(@products, @current_delivery_cycle)
    @products = Product.alphabetize(@products).paginate(:page => page, :per_page => 10)
    @root_categories = Category.root_categories
    
    if params[:account_id]
      @account = Account.find(params[:account_id])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new 
    @product.account = @account
    @categories = Category.all
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @categories = Category.all
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.new(params[:product])
    @product.account = @account
    respond_to do |format|
      if @product.save
        flash[:notice] = 'Product was successfully created.'
        format.html { 
          if params[:add_another]
            redirect_to new_account_product_path(@account)
          else
            redirect_to account_path(@account) 
          end 
        }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    respond_to do |format|
      if @product.update_attributes(params[:product])
        flash[:notice] = 'Product was successfully updated.'
        format.html { redirect_to account_products_path(@account) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(account_url(@account)) }
      format.xml  { head :ok }
    end
  end
  
  def make_orderable
    number = params[:number].to_i
    number.times do |i|
      break unless @current_delivery_cycle
      o = Orderable.create(:product_id => @product.id, :status => 'Available', :delivery_cycle_id => @current_delivery_cycle.id)
      o.save
    end 
    respond_to do |format|
      format.js
    end
  end
  
  def remove_orderable
    number = params[:number].to_i
    if number and number > 0
      number.times do |i|
        break unless @current_delivery_cycle
        o = Orderable.find(:first, :conditions => ["status = 'Available' and delivery_cycle_id = ?", @current_delivery_cycle.id])
        if o
          o.destroy
        else
          break
        end
      end
    end
    respond_to do |format|
      format.js
    end 
  end 
  
  def add_to_cart
    success = false
    @user = User.find(params[:user_id])
    number = params[:number].to_i 
    if number and number > 0
      number.times do |i|
        orderable = @product.available_orderables_in_cycle(@current_delivery_cycle).first
        if orderable
          @order = @user.current_order
          if !@order
            @order = Order.create(:user_id => @user.id, :delivery_cycle => @current_delivery_cycle)
          end
          if @order
            @line_item = @order.line_item_for_product(@product) || LineItem.create(:order_id => @order.id, :product_id => @product.id)
            if @line_item.save
              orderable.update_attributes(:status => 'In Cart', :line_item_id => @line_item.id)
              if !orderable.save 
                break
              end
            end
          end
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end
  
  def load_product 
    @product = Product.find(params[:id])
  end
  
  def load_account
    @account = nil
    @account = Account.find(params[:account_id]) if (params[:account_id])
    unless @account
      flash[:notice] = "A specific account is required for this action."
      redirect_to products_url
    end
  end
  
  def is_owner_or_admin
    unless current_user and (current_user.managed_accounts.include?(@product.account) or current_user.admin)
      flash[:notice] = "You are not authorized to perform this action."
      redirect_to product_url(@product)
    end
  end
  
  def ordering_and_delivery_closed
    unless !@current_delivery_cycle or (@current_delivery_cycle and @current_delivery_cycle.permits_product_editing)
      flash[:notice] = "You cannot edit or delete products during the ordering and delivery phases of a delivery cycle"
      if @account and @product
        redirect_to account_product_url(@account,@product)
      elsif @product
        redirect_to product_url(@product)
      elsif @account
        redirect_to account_products_url(@account)
      else
        redirect_to products_url
      end
    end
  end
  
  def can_make_orderable
    if !@current_delivery_cycle
      flash[:notice] = "You cannot add inventory when there is no current delivery cycle." 
      redirect_to products_url
    elsif !@product.can_make_orderable(@current_delivery_cycle)
      flash[:notice] = "You cannot make this product orderable until the current ordering period ends."
      redirect_to products_url
    end
  end
  
end
