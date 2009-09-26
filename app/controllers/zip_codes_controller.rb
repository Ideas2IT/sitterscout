class ZipCodesController < ApplicationController
  # GET /zip_codes
  # GET /zip_codes.xml
  def index
    @zip_codes = ZipCode.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @zip_codes }
    end
  end

  # GET /zip_codes/1
  # GET /zip_codes/1.xml
  def show
    @zip_code = ZipCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @zip_code }
    end
  end

  # GET /zip_codes/new
  # GET /zip_codes/new.xml
  def new
    @zip_code = ZipCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @zip_code }
    end
  end

  # GET /zip_codes/1/edit
  def edit
    @zip_code = ZipCode.find(params[:id])
  end

  # POST /zip_codes
  # POST /zip_codes.xml
  def create
    @zip_code = ZipCode.new(params[:zip_code])

    respond_to do |format|
      if @zip_code.save
        flash[:notice] = 'ZipCode was successfully created.'
        #flash.discard
        format.html { redirect_to(@zip_code) }
        format.xml  { render :xml => @zip_code, :status => :created, :location => @zip_code }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @zip_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /zip_codes/1
  # PUT /zip_codes/1.xml
  def update
    @zip_code = ZipCode.find(params[:id])

    respond_to do |format|
      if @zip_code.update_attributes(params[:zip_code])
        flash[:notice] = 'ZipCode was successfully updated.'
        #flash.discard
        format.html { redirect_to(@zip_code) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @zip_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /zip_codes/1
  # DELETE /zip_codes/1.xml
  def destroy
    @zip_code = ZipCode.find(params[:id])
    @zip_code.destroy

    respond_to do |format|
      format.html { redirect_to(zip_codes_url) }
      format.xml  { head :ok }
    end
  end
end
