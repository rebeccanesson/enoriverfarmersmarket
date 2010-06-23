class Admin::DeliveryCyclesController < Admin::AdminController
  # GET /delivery_cycles
  # GET /delivery_cycles.xml
  def index
    @delivery_cycles = DeliveryCycle.find(:all, :order => 'pickup_close DESC')

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
        format.html { redirect_to(admin_delivery_cycles_path) }
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
  
  def duplicate
    start_date = DateTime.civil(params[:delivery_cycle][:"start_date(1i)"].to_i,
                                params[:delivery_cycle][:"start_date(2i)"].to_i,
                                params[:delivery_cycle][:"start_date(3i)"].to_i, 
                                params[:delivery_cycle][:"start_date(4i)"].to_i, 
                                params[:delivery_cycle][:"start_date(5i)"].to_i)
    logger.debug("start_date is #{start_date}")
    dc = DeliveryCycle.find(params[:id])
    logger.debug("dc is #{dc.inspect}")
    logger.debug("edit open is #{start_date}")
    logger.debug("start_date is #{start_date}, edit open is #{dc.edit_open}, edit close is #{dc.edit_close}")
    logger.debug("dc.edit_close - dc.edit_open is #{dc.edit_close - dc.edit_open}")
    logger.debug("start_date + 86400 is #{start_date + 86400}, start_date + 86400/(60*60) is #{start_date + (86400/(60*60))}")
    logger.debug("edit close is #{start_date + (dc.edit_close     - dc.edit_open)}")
    logger.debug("start_date is #{start_date}, edit open is #{dc.edit_open}")
    logger.debug("order open is #{start_date + (dc.order_open - dc.edit_open)}")
    logger.debug("start_date is #{start_date}, edit open is #{dc.edit_open}")
    new_dc = DeliveryCycle.new(:edit_open      => start_date, 
                               :edit_close     => start_date + ((dc.edit_close     - dc.edit_open) / 86400), 
                               :order_open     => start_date + ((dc.order_open     - dc.edit_open) / 86400), 
                               :order_close    => start_date + ((dc.order_close    - dc.edit_open) / 86400), 
                               :delivery_open  => start_date + ((dc.delivery_open  - dc.edit_open) / 86400), 
                               :delivery_close => start_date + ((dc.delivery_close - dc.edit_open) / 86400), 
                               :pickup_open    => start_date + ((dc.pickup_open    - dc.edit_open) / 86400), 
                               :pickup_close   => start_date + ((dc.pickup_close   - dc.edit_open) / 86400))

    respond_to do |format|
       if new_dc.save
         flash[:notice] = 'DeliveryCycle was successfully duplicated.'
         format.html { redirect_to(admin_delivery_cycles_path) }
       else
        logger.debug("errors are: #{new_dc.errors.inspect}")
         format.html { 
                       redirect_to(admin_delivery_cycles_path) 
                     }
         format.xml  { render :xml => @delivery_cycle.errors, :status => :unprocessable_entity }
       end
     end
  end
  
end
