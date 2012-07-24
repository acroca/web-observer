class Petition < ActiveRecord::Base
  attr_accessible :callback_url, :css_selector, :request_url

  validates_format_of :request_url, :with => URI::regexp(%w(http https))
end
