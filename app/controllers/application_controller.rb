class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

  def render_not_found_response(exception)
    render json: { error: exception.message }, status: 404
  end

  def render_record_invalid(exception)
    render json: { error: exception.message }, status: 400
  end
end
