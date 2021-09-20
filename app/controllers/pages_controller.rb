class PagesController < ApplicationController
  
    before_action :find_page_by_permalink, only: :show
    
    layout 'users'
    
    # GET /pages/permalink
    def show
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    private
    
    def find_page_by_permalink
      if params[:permalink]
        @page = Page.find_by_permalink(params[:permalink])
        raise ActiveRecord::RecordNotFound, "Page not found" if @page.nil?
      end
    end
  end
  