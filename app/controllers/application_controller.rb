class ApplicationController < ActionController::Base
  def not_found
    render status: :not_found, inline: ''
  end
end
