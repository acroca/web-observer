require 'spec_helper'

describe Executor do
  describe "simple execution" do
    let(:content) { "<div>1</div><div>content</div><h1>3</h1>" }
    let(:css_selector) { "div:nth(2)" }
    let(:expected) { 'content' }
    let(:old_value) { nil } 
    
    let(:response) { {:body => content} }
    let!(:request){ stub_http_request(:get, "http://www.example.com/req").to_return(response) }
    let!(:callback) { stub_http_request(:post, "http://www.example.com/cb").with(:body => expected) }
    let(:queue_callback) { lambda{|v| @value = v } }

    before do 
      @value = nil
      executor = Executor.new
      executor.queue('http://www.example.com/req', css_selector, old_value, 'http://www.example.com/cb', &queue_callback)
      executor.run
    end  

    it "works" do
      request.should have_been_requested
      callback.should have_been_requested
    end
  
    it "yields the new value the queue callback" do
      @value.should == expected
    end

    context "when the old value is the same as the new value" do
      let(:old_value) { expected }
      it "doesn't call the callback" do
        request.should have_been_requested
        callback.should_not have_been_requested
        @value.should be_nil
      end
    end

    context "when the response is not 2xx" do
      let(:response) { {:status => 404} }
      it "doesn't call the callback" do
        request.should have_been_requested
        callback.should_not have_been_requested
        @value.should be_nil
      end
    end

    context "when the css query returns nothing" do
      let(:response) { {body: '<span>something</span>'} }
      let(:css_selector) { 'div' }
      
      it "doesn't call the callback" do
        request.should have_been_requested
        callback.should_not have_been_requested
        @value.should be_nil
      end
    end

    context "when the content is not parseable" do
      let(:response) { {body: '--------'} }
      
      it "doesn't call the callback" do
        request.should have_been_requested
        callback.should_not have_been_requested
        @value.should be_nil
      end
    end

  end

  it "executes multple items in queue" do
    r1 = stub_http_request(:get, "http://www.example.com/1/req").to_return(body: '<div>1</div>')
    r2 = stub_http_request(:get, "http://www.example.com/2/req").to_return(body: '<span>2</span>')
    c1 = stub_http_request(:post, "http://www.example.com/1/cb").with(:body => '1')
    c2 = stub_http_request(:post, "http://www.example.com/2/cb").with(:body => '2')

    c1_v = c2_v = nil
    executor = Executor.new
    executor.queue('http://www.example.com/1/req', 'div', nil, 'http://www.example.com/1/cb') { |v| c1_v = v}
    executor.queue('http://www.example.com/2/req', 'span', nil, 'http://www.example.com/2/cb'){ |v| c2_v = v}
    executor.run

    r1.should have_been_requested
    r2.should have_been_requested
    c1.should have_been_requested
    c2.should have_been_requested
    c1_v.should == '1'
    c2_v.should == '2'
  end 

  

end