class ApiController < ApplicationController
  before_action :authorize_xml
  before_action :authenticate_user!
end