class Admin::PaymentsController < AdminController
  
    load_and_authorize_resource
    before_action :authenticate_user!
    
    # GET /admin/payments
    def index
      @payments = Payment.order(:paid_at, :amount, :id).load

      respond_to do |format|
        format.html # index.html.erb
        format.xlsx { render xlsx: "index", filename: "payments.xlsx" }
      end
    end
  
    # GET /admin/payments/invoices
    def invoices
      @payments = Payment.unreconciled.includes(:group).order('groups.short_name', :id).load

      respond_to do |format|
        format.html # invoices.html.erb
      end
    end
  
    # GET /admin/payments/1
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/payments/new
    def new
      @payment.paid_at = Date.today

      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/payments/1/edit
    def edit
    end
  
    # POST /admin/payments
    def create
      @payment = Payment.new(payment_params)
      @payment.payment_type = 'Invoice'
      @payment.updated_by = current_user.id

      respond_to do |format|
        if @payment.save
          flash[:notice] = 'Payment was successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PATCH /admin/payments/1
    def update
      @payment.updated_by = current_user.id

      respond_to do |format|
        if @payment.update(payment_params)
          flash[:notice] = 'Payment was successfully updated.'
          format.html { redirect_to admin_payments_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # PATCH /admin/payments/1/reconcile
    def reconcile
      @payment.reconciled = true
      @payment.paid = true
      @payment.updated_by = current_user.id

      respond_to do |format|
        if @payment.save
          flash[:notice] = 'Payment reconciled.'
          format.html { redirect_to admin_payments_url }
        end
      end
    end
  
    # DELETE /admin/payments/1
    def destroy
      flash[:notice] = 'Payment deleted.'
      @payment.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_payments_url }
      end
    end
  
    private
    
    def payment_params
      params.require(:payment).permit(
        :amount, 
        :group_id,
        :invoice_type,
        :reconciled,
        :paid,
        :paid_at,
        :reference
      )
    end
end
  