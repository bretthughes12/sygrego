class Admin::AwardsController < ApplicationController

  load_and_authorize_resource
  layout 'admin'
  
  # GET /admin/awards/good_sports
  def good_sports
    @awards = Award.good_sports.order('flagged desc, name').load

    respond_to do |format|
      format.html # good_sports.html.erb
      format.csv  { render_csv "good_sports", "awards" }
    end
  end
  
  # GET /admin/awards/spirit
  def spirit
    @awards = Award.spirit.order('flagged desc, name').load

    respond_to do |format|
      format.html # spirit.html.erb
      format.csv  { render_csv "spirit", "awards" }
    end
  end
  
  # GET /admin/awards/volunteer_awards
  def volunteer_awards
    @awards = Award.volunteer.order('flagged desc, name').load

    respond_to do |format|
      format.html # volunteer_awards.html.erb
      format.csv  { render_csv "volunteer_awards", "awards" }
    end
  end
  
  # GET /admin/awards/new_good_sports
  def new_good_sports
    @award = Award.new

    respond_to do |format|
      format.html # new_good_sports.html.erb
    end
  end
  
  # GET /admin/awards/new_spirit
  def new_spirit
    @award = Award.new

    respond_to do |format|
      format.html # new_spirit.html.erb
    end
  end
  
  # GET /admin/awards/new_volunteer
  def new_volunteer
    @award = Award.new

    respond_to do |format|
      format.html # new_volunteer.html.erb
    end
  end
  
  # GET /admin/award/1/edit_good_sports
  def edit_good_sports
    @award = Award.find(params[:id])

    respond_to do |format|
      format.html # edit_good_sports.html.erb
    end
  end
  
  # GET /admin/award/1/edit_spirit
  def edit_spirit
    @award = Award.find(params[:id])

    respond_to do |format|
      format.html # edit_spirit.html.erb
    end
  end
  
  # GET /admin/award/1/edit_volunteer
  def edit_volunteer
    @award = Award.find(params[:id])

    respond_to do |format|
      format.html # edit_volunteer.html.erb
    end
  end

  # POST /admin/awards/create_good_sports
  def create_good_sports
    @award = Award.new(award_params)
    @award.category = 'Good Sports'

    respond_to do |format|
      if @award.save
          flash[:notice] = 'Thanks for your nomination. Nominate another?'
          format.html do
            redirect_to good_sports_admin_awards_url
          end
      else
          format.html { render action: "new_good_sports" }
      end
    end
  end

  # POST /admin/awards/create_spirit
  def create_spirit
    @award = Award.new(award_params)
    @award.category = 'Spirit'

    respond_to do |format|
      if @award.save
          flash[:notice] = 'Thanks for your nomination. Nominate another?'
          format.html do
            redirect_to spirit_admin_awards_url
          end
      else
          format.html { render action: "new_spirit" }
      end
    end
  end

  # POST /admin/awards/create_volunteer
  def create_volunteer
    @award = Award.new(award_params)
    @award.category = 'Volunteer'

    respond_to do |format|
      if @award.save
          flash[:notice] = 'Thanks for your nomination. Nominate another?'
          format.html do
            redirect_to volunteer_awards_admin_awards_url
          end
      else
          format.html { render action: "new_volunteer" }
      end
    end
  end

  # PATCH /admin/awards/update_good_sports
  def update_good_sports
    @award = Award.find(params[:id])

    respond_to do |format|
      if @award.update(award_params)
          flash[:notice] = 'Nomination was successfully updated.'
          format.html do
            redirect_to good_sports_admin_awards_url
          end
      else
          format.html { render action: "new_good_sports" }
      end
    end
  end

  # PATCH /admin/awards/update_spirit
  def update_spirit
    @award = Award.find(params[:id])

    respond_to do |format|
      if @award.update(award_params)
          flash[:notice] = 'Nomination was successfully updated.'
          format.html do
            redirect_to spirit_admin_awards_url
          end
      else
          format.html { render action: "new_spirit" }
      end
    end
  end

  # PATCH /admin/awards/update_volunteer
  def update_volunteer
    @award = Award.find(params[:id])

    respond_to do |format|
      if @award.update(award_params)
          flash[:notice] = 'Nomination was successfully updated.'
          format.html do
            redirect_to volunteer_awards_admin_awards_url
          end
      else
          format.html { render action: "new_volunteer" }
      end
    end
  end

  # PATCH /admin/awards/flag_good_sports
  def flag_good_sports
    @award = Award.find(params[:id])
    @award.flagged = true
    @award.save

    respond_to do |format|
      format.html do
        redirect_to good_sports_admin_awards_url
      end
    end
  end

  # PATCH /admin/awards/flag_spirit
  def flag_spirit
    @award = Award.find(params[:id])
    @award.flagged = true
    @award.save

    respond_to do |format|
      format.html do
        redirect_to spirit_admin_awards_url
      end
    end
  end

  # PATCH /admin/awards/flag_volunteer
  def flag_volunteer
    @award = Award.find(params[:id])
    @award.flagged = true
    @award.save

    respond_to do |format|
      format.html do
        redirect_to volunteer_awards_admin_awards_url
      end
    end
  end

  # DELETE /admin/awards/1/destroy_good_sports
  def destroy_good_sports
    @award.destroy

    respond_to do |format|
      format.html { redirect_to good_sports_admin_awards_url }
    end
  end

  # DELETE /admin/awards/1/destroy_spirit
  def destroy_spirit
    @award.destroy

    respond_to do |format|
      format.html { redirect_to spirit_admin_awards_url }
    end
  end

  # DELETE /admin/awards/1/destroy_volunteer
  def destroy_volunteer
    @award.destroy

    respond_to do |format|
      format.html { redirect_to volunteer_awards_admin_awards_url }
    end
  end

  private

  def award_params
    params.require(:award).permit(
      :award_type,
      :name, 
      :flagged,
      :submitted_by, 
      :submitted_group,
      :description
    )
  end
end  