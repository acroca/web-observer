class ApplicationController < ActionController::Base
  protect_from_forgery

  def test
    render text: 'Hi', layout: true
  end
end
