class ProductsController < ApplicationController
  # GET /products
  # GET /products.xml
  
  before_filter :load_product, :only => [:show, :edit, :update, :destroy]
  before_filter :load_account, :except => [:index, :show]
  before_filter :is_owner_or_admin, :only => [:edit, :update, :destroy]
  before_filter :load_sidebar_variables, :only => [:index]
  
  def index
    @search = Product.search(params[:search])
    @products = @search.all
    @facets = Product.facet(@products)
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
        format.html { redirect_to account_products_path(@account) }
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
      format.html { redirect_to(account_products_url(@account)) }
      format.xml  { head :ok }
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
end
