class AwardsController < ApplicationController
  
    layout 'users'
    
    # GET /awards/new_sport_nominations
    # GET /sport_nomination
    def new_sport_nomination
      respond_to do |format|
        format.html # sport_nomination.html.erb
      end
    end
    
    # GET /awards/new_spirit
    # GET /spirit
    def new_spirit
        respond_to do |format|
          format.html # spirit.html.erb
        end
      end
      
    # GET /awards/new_legend
    # GET /legend
    def new_legend
        respond_to do |format|
          format.html # legend.html.erb
        end
      end
  end
  