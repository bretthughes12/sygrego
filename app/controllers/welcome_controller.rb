class WelcomeController < ApplicationController

    def home
        redirect_to home_url(current_user)
    end
end
