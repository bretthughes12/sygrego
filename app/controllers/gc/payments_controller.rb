class Gc::PaymentsController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user!
    before_action :find_group
    
    layout "gc" 
  
    # GET /gc/payments
    def index
      @payments = @group.payments.
        order(:paid_at).load
  
      respond_to do |format|
        format.html do
          render layout: @current_role.name
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
              format.html { render action: "edit", layout: @current_role.name }
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
end
