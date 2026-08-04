class Api::V1::ParticipantsController < ApplicationController
  before_action :set_participant, only: [:show, :update, :destroy]

  def index
    participants = Participant.all
    render json: participants
  end

  def show
    render json: @participant, serializer: Api::V1::ParticipantSerializer
  end

  def create
    participant = Participant.new(participant_params)

    if participant.save
      render json: participant, status: :created
    else
      render json: { errors: participant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @participant.update(participant_params)
      render json: @participant
    else
      render json: { errors: @participant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @participant.destroy
    head :no_content
  end

  private

  def set_participant
    @participant = Participant.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Participant not found' }, status: :not_found
  end

  def participant_params
    params.require(:participant).permit(:name, :email, :phone, :status)
  end
end
