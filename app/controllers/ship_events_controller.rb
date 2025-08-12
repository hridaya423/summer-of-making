class ShipEventsController < ApplicationController
  before_action :set_ship_event, only: [:feedback, :regenerate_feedback]
  before_action :require_admin!, only: [:regenerate_feedback]

  def feedback
    if @ship_event.has_feedback?
      render json: { 
        feedback: @ship_event.feedback,
        ship_event_id: @ship_event.id 
      }
    else
      render json: { 
        error: "No feedback available" 
      }, status: 404
    end
  end

  def regenerate_feedback
    begin
      service = ShipFeedbackService.new(@ship_event)
      feedback = service.generate_feedback
      
      if feedback
        render json: { 
          success: true,
          message: "Feedback regenerated successfully",
          feedback: feedback,
          ship_event_id: @ship_event.id
        }
      else
        render json: {
          success: false,
          message: "Failed to generate feedback - check logs for details"
        }, status: 422
      end
    rescue => e
      Rails.logger.error "Admin feedback regeneration failed for ship_event #{@ship_event.id}: #{e.message}"
      render json: {
        success: false,
        message: "An error occurred while regenerating feedback"
      }, status: 500
    end
  end

  private

  def set_ship_event
    @ship_event = ShipEvent.find(params[:id])
  end

  def require_admin!
    unless current_user&.is_admin?
      render json: { error: "Admin access required" }, status: 403
    end
  end
end