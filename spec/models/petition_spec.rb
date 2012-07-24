require 'spec_helper'

describe Petition do
  subject { FactoryGirl.build(:petition) }
  
  describe :request_url do
    it { should allow_value("http://www.example.com/test").for(:request_url) }
    it { should allow_value("https://www.example.com/test").for(:request_url) }
    it { should_not allow_value("www.example.com/test").for(:request_url) }
    it { should_not allow_value("ftp://www.example.com/test").for(:request_url) }
  end

  describe :callback_url do
    it { should allow_value("http://www.example.com/test").for(:request_url) }
    it { should allow_value("https://www.example.com/test").for(:request_url) }
    it { should_not allow_value("www.example.com/test").for(:request_url) }
    it { should_not allow_value("ftp://www.example.com/test").for(:request_url) }
  end

end
