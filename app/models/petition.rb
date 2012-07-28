class Petition < ActiveRecord::Base
  attr_accessible :name, :callback_url, :css_selector, :request_url

  validates :request_url, presence: true, format: URI::regexp(%w(http https))
  validates :callback_url, presence: true, format: URI::regexp(%w(http https))
  validates :name, presence: true
  validates :css_selector, presence: true
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
