class Admin::VouchersController < AdminController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    # GET /admin/vouchers
    def index
      @vouchers = Voucher.order(:name).load

      respond_to do |format|
        format.html # index.html.erb
        format.csv  { render_csv "voucher", "voucher" }
        format.xlsx { render xlsx: "index", filename: "vouchers.xlsx" }
      end
    end
  
    # GET /admin/vouchers/1
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/vouchers/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/vouchers/1/edit
    def edit
    end
  
    # POST /admin/vouchers
    def create
      @voucher = Voucher.new(voucher_params)

      respond_to do |format|
        if @voucher.save
          flash[:notice] = 'Voucher was successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PATCH /admin/vouchers/1
    def update
      respond_to do |format|
        if @voucher.update(voucher_params)
          flash[:notice] = 'Voucher was successfully updated.'
          format.html { redirect_to admin_vouchers_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/vouchers/1
    def destroy
      flash[:notice] = 'Voucher deleted.'
      @voucher.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_vouchers_url }
      end
    end
  
    private
    
    def voucher_params
      params.require(:voucher).permit(
        :name, 
        :group_id,
        :limit,
        :expiry,
        :voucher_type,
        :adjustment
      )
    end
  end
  