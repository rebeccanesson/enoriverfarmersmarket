class Admin::DeliveryCyclesController < Admin::AdminController
  # GET /delivery_cycles
  # GET /delivery_cycles.xml
  def index
    @delivery_cycles = DeliveryCycle.find(:all, :order => 'edit_open ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @delivery_cycles }
    end
  end

  # GET /delivery_cycles/1
  # GET /delivery_cycles/1.xml
  def show
    @delivery_cycle = DeliveryCycle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @delivery_cycle }
    end
  end

  # GET /delivery_cycles/new
  # GET /delivery_cycles/new.xml
  def new
    @delivery_cycle = DeliveryCycle.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @delivery_cycle }
    end
  end

  # GET /delivery_cycles/1/edit
  def edit
    @delivery_cycle = DeliveryCycle.find(params[:id])
  end

  # POST /delivery_cycles
  # POST /delivery_cycles.xml
  def create
    @delivery_cycle = DeliveryCycle.new(params[:delivery_cycle])

    respond_to do |format|
      if @delivery_cycle.save
        flash[:notice] = 'DeliveryCycle was successfully created.'
        format.html { redirect_to(admin_delivery_cycle_path(@delivery_cycle)) }
        format.xml  { render :xml => @delivery_cycle, :status => :created, :location => @delivery_cycle }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @delivery_cycle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /delivery_cycles/1
  # PUT /delivery_cycles/1.xml
  def update
    @delivery_cycle = DeliveryCycle.find(params[:id])

    respond_to do |format|
      if @delivery_cycle.update_attributes(params[:delivery_cycle])
        flash[:notice] = 'DeliveryCycle was successfully updated.'
        format.html { redirect_to(admin_delivery_cycle_path(@delivery_cycle)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @delivery_cycle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /delivery_cycles/1
  # DELETE /delivery_cycles/1.xml
  def destroy
    @delivery_cycle = DeliveryCycle.find(params[:id])
    @delivery_cycle.destroy

    respond_to do |format|
      format.html { redirect_to(admin_delivery_cycles_url) }
      format.xml  { head :ok }
    end
  end
end
