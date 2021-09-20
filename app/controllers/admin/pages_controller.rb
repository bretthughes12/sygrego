class Admin::PagesController < ApplicationController
  
    load_and_authorize_resource except: [:show]
    before_action :authenticate_user!
    
    layout 'admin'
    
    # GET /admin/pages
    def index
      @pages = Page.order(:name).load

      respond_to do |format|
        format.html # index.html.erb
      end
    end
  
    # GET /admin/pages/1
    def show
      @page = Page.find(params[:id])
      authorize! :show, @page

      respond_to do |format|
        format.html # show.html.erb
      end
    end
  
    # GET /admin/pages/new
    def new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  
    # GET /admin/pages/1/edit
    def edit
    end
  
    # POST /admin/pages
    def create
      respond_to do |format|
        if @page.save
          flash[:notice] = 'Page was successfully created.'
          format.html { render action: "edit" }
        else
          format.html { render action: "new" }
        end
      end
    end
  
    # PUT /admin/pages/1
    def update
      respond_to do |format|
        if @page.update(page_params)
          flash[:notice] = 'Page was successfully updated.'
          format.html { redirect_to admin_pages_url }
        else
          format.html { render action: "edit" }
        end
      end
    end
  
    # DELETE /admin/pages/1
    def destroy
      @page.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_pages_url }
      end
    end
  
    private
    
    def page_params
      params.require(:page).permit(:name, 
                                   :permalink,
                                   :content,
                                   :admin_use)
    end
  end
  