class CallbackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.info { " -- [CallbackController]: #{request.body.read}" }

    unless Line::Callback.validate_signature? request
      render status: 400, text: 'Bad Request' and return
    else
      Line::Callback.parse request
      render text: "OK" and return
    end
  end
end
