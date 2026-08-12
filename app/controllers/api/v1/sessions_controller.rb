module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

#      protect_from_forgery with: :null_session

      private

      def respond_with(resource, _opts = {})
        render json: { 
          status: { code: 200, message: 'Logged in successfully.' },
#          data: Api::V1::UserSerializer.new(resource).serializable_hash[:data][:attributes]
          data: Api::V1::UserSerializer.new(resource)
        }, 
        status: :ok
      end

      def respond_to_on_destroy(*args)
        if current_api_user
          render json: { 
            status: { code: 200, message: 'Logged out successfully.' }
          }, 
          status: :ok
        else
          render json: { 
            status: { code: 401, message: 'Logged out failure.' } 
          }, 
          status: :unauthorized
        end
      end
    end
  end
end
