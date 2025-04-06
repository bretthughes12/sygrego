class Gc::PaymentsController < GcController
    load_and_authorize_resource
  
    # GET /gc/payments
    def index
      @payments = @group.payments.paid.
        order(:paid_at).load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
        end
        format.pdf  do
          output = FinanceReport.new.add_data(@group, @payments).to_pdf
          
          render_pdf output, 'account-summary'
        end
      end
    end

    # GET /gc/payments/1
    def show
      render layout: @current_role.name
    end
  
    # GET /gc/payments/new
    def new
      @payment.paid_at = Date.today

      respond_to do |format|
        format.html { render layout: @current_role.name }
      end
    end
  
    # GET /gc/payments/1/edit
    def edit
      render layout: @current_role.name
    end
  
    # POST /admin/payments
    def create
      @payment = Payment.new(payment_params)
      @payment.group_id = @group.id
      @payment.updated_by = current_user.id

      respond_to do |format|
          if @payment.save
              flash[:notice] = 'Payment was successfully created.'
              format.html { redirect_to gc_payments_url }
          else
              format.html { render action: "new", layout: @current_role.name }
          end
      end
    end

    # PATCH /gc/payments/1
    def update
      case 
      when @payment.reconciled
        flash[:notice] = 'Payment is reconciled and cannot be updated.'

        respond_to do |format|
          format.html { render action: "edit", layout: @current_role.name }
        end

      else
        @payment.updated_by = current_user.id

        respond_to do |format|
          if @payment.update(payment_params)
            flash[:notice] = 'Details were successfully updated.'
            format.html { redirect_to gc_payments_url }
          else
            format.html { render action: "edit", layout: @current_role.name }
          end
        end
      end
    end
  
    # PATCH /gc/payments/1/paid
    def paid
      @payment.paid = true
      @payment.paid_at = Date.today
      @payment.updated_by = current_user.id

      respond_to do |format|
        @payment.update(paid_payment_params)

        format.html { redirect_to gc_payments_url }
      end
    end
  
    # DELETE /admin/payments/1
    def destroy
      case 
      when @payment.reconciled
        flash[:notice] = 'Payment is reconciled and cannot be deleted.'
      else
        flash[:notice] = 'Payment deleted.'
        @payment.destroy
      end

      respond_to do |format|
          format.html { redirect_to gc_payments_url }
      end
    end
  
    private
  
    def payment_params
      params.require(:payment).permit(
        :amount, 
        :paid_at,
        :payment_type,
        :name,
        :reference
      )
    end
  
    def paid_payment_params
      params.require(:payment).permit(
        :amount, 
        :reference
      )
    end
end
