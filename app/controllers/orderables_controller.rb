class OrderablesController < ApplicationController
  # GET /orderables
  # GET /orderables.xml
  def index
    @orderables = Orderable.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orderables }
    end
  end

  # GET /orderables/1
  # GET /orderables/1.xml
  def show
    @orderable = Orderable.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @orderable }
    end
  end

  # GET /orderables/new
  # GET /orderables/new.xml
  def new
    @orderable = Orderable.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @orderable }
    end
  end

  # GET /orderables/1/edit
  def edit
    @orderable = Orderable.find(params[:id])
  end

  # POST /orderables
  # POST /orderables.xml
  def create
    @orderable = Orderable.new(params[:orderable])

    respond_to do |format|
      if @orderable.save
        flash[:notice] = 'Orderable was successfully created.'
        format.html { redirect_to(@orderable) }
        format.xml  { render :xml => @orderable, :status => :created, :location => @orderable }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @orderable.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /orderables/1
  # PUT /orderables/1.xml
  def update
    @orderable = Orderable.find(params[:id])

    respond_to do |format|
      if @orderable.update_attributes(params[:orderable])
        flash[:notice] = 'Orderable was successfully updated.'
        format.html { redirect_to(@orderable) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @orderable.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /orderables/1
  # DELETE /orderables/1.xml
  def destroy
    @orderable = Orderable.find(params[:id])
    @orderable.destroy

    respond_to do |format|
      format.html { redirect_to(orderables_url) }
      format.xml  { head :ok }
    end
  end
end
