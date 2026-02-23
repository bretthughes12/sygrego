class PaymentsController < ApplicationController
    load_and_authorize_resource

    # GET /payments/:id/receipt
    def receipt
        redirect_to rails_blob_path(@payment.receipt)
    end
end
