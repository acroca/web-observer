class Petition < ActiveRecord::Base
  attr_accessible :callback_url, :css_selector, :request_url

  validates_format_of :request_url, :with => URI::regexp(%w(http https))
  validates_format_of :callback_url, :with => URI::regexp(%w(http https))
  validate :css_selector_format

  scope :next_batch, order("last_check ASC").limit(100)

  private

  def css_selector_format
    begin
      Nokogiri::CSS::Parser.new.parse self.css_selector
    rescue
      self.errors[:css_selector] << "is not a proper CSS selector"
    end
  end
end
