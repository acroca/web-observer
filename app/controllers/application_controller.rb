class ApplicationController < ActionController::Base
  protect_from_forgery

  if ENV["HTTP_USERNAME"] && ENV['HTTP_PASSWORD']
    http_basic_authenticate_with :name => ENV["HTTP_USERNAME"], :password => ENV['HTTP_PASSWORD']
  end
end
