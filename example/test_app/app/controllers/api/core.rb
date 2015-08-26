
class Api::Core  < ApplicationController

  before_filter :dump_parameters


  def require_api_authorization
    unless Rails.env.development?
      if request.parameters['Envelope'].present? && request.parameters['Envelope']['Header'].present? &&  request.parameters['Envelope']['Header']['authToken'].present? &&  request.parameters['Envelope']['Header']['authToken']== TestApp::Application.config.api__auth_token
        return true
      else
        head :forbidden
      end
    end
  end

  def dump_parameters
    Rails.logger.debug params.inspect if Rails.env.development?
  end
end
