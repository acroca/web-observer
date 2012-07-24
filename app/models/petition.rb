class Petition < ActiveRecord::Base
  attr_accessible :callback_url, :css_selector, :request_url
end
