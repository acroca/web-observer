require 'spec_helper'

describe Petition do
  subject { FactoryGirl.build(:petition) }
  
  describe :name do
    it { should allow_value("Fringe last episode").for(:name) }
    it { should_not allow_value("").for(:name) }
  end

  describe :request_url do
    it { should allow_value("http://www.example.com/test").for(:request_url) }
    it { should allow_value("https://www.example.com/test").for(:request_url) }
    it { should_not allow_value("www.example.com/test").for(:request_url) }
    it { should_not allow_value("ftp://www.example.com/test").for(:request_url) }
  end

  describe :callback_url do
    it { should allow_value("http://www.example.com/test").for(:callback_url) }
    it { should allow_value("https://www.example.com/test").for(:callback_url) }
    it { should_not allow_value("www.example.com/test").for(:callback_url) }
    it { should_not allow_value("ftp://www.example.com/test").for(:callback_url) }
  end

  describe :css_selector do
    it { should allow_value("body > div.test a:nth-child(2)").for(:css_selector) }
    it { should_not allow_value("-").for(:css_selector) }
  end

end
