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
    let(:queue_callback) { lambda{|v, e| @value = v; @exception = e } }

    before do 
      @value = nil
      @exception = nil
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
        @exception.should be_kind_of(Executor::InvalidResponseCode)
      end
    end

    context "when the css query returns nothing" do
      let(:response) { {body: '<span>something</span>'} }
      let(:css_selector) { 'div' }
      
      it "doesn't call the callback" do
        request.should have_been_requested
        callback.should_not have_been_requested
        @value.should be_nil
        @exception.should be_kind_of(Executor::ElementNotFound)
      end
    end

    context "when the content is not parseable" do
      let(:response) { {body: '--------'} }
      
      it "doesn't call the callback" do
        request.should have_been_requested
        callback.should_not have_been_requested
        @value.should be_nil
        @exception.should be_kind_of(Executor::ElementNotFound)
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
    executor.queue('http://www.example.com/1/req', 'div', nil, 'http://www.example.com/1/cb') { |v,e| c1_v = v}
    executor.queue('http://www.example.com/2/req', 'span', nil, 'http://www.example.com/2/cb'){ |v,e| c2_v = v}
    executor.run

    r1.should have_been_requested
    r2.should have_been_requested
    c1.should have_been_requested
    c2.should have_been_requested
    c1_v.should == '1'
    c2_v.should == '2'
  end 

  describe ".process_batch" do
    it 'updaes the last_value' do
      petition = FactoryGirl.create(:petition)
      Petition.stub(:next_batch){ [petition] }
      Executor.any_instance.should_receive(:queue).with(
        petition.request_url,
        petition.css_selector,
        petition.last_value,
        petition.callback_url).and_yield("the new value", nil)

      Executor.any_instance.should_receive(:run)
      expect {
        Executor.process_batch
      }.to change{petition.reload.last_value}.to("the new value")
    end

    it 'updates the last_check even without yielding' do
      petition = FactoryGirl.create(:petition)
      Petition.stub(:next_batch){ [petition] }
      Executor.any_instance.should_receive(:queue).with(
        petition.request_url,
        petition.css_selector,
        petition.last_value,
        petition.callback_url)

      Executor.any_instance.should_receive(:run)
      expect {
        Executor.process_batch
      }.to change{petition.reload.last_check}
    end

    it 'processes multiple petitions' do
      petitions = [FactoryGirl.create(:petition, css_selector: 'h1'), FactoryGirl.create(:petition, css_selector: 'h2')]
      Petition.stub(:next_batch){ petitions }
      Executor.any_instance.should_receive(:queue).with(
        petitions.first.request_url,
        petitions.first.css_selector,
        petitions.first.last_value,
        petitions.first.callback_url).and_yield("the new value for the first one", nil)
      Executor.any_instance.should_receive(:queue).with(
        petitions.second.request_url,
        petitions.second.css_selector,
        petitions.second.last_value,
        petitions.second.callback_url).and_yield("the new value for the second one", nil)

      Executor.any_instance.should_receive(:run)
      expect {
        expect {
          Executor.process_batch
        }.to change{petitions.first.reload.last_value}.to("the new value for the first one")
      }.to change{petitions.second.reload.last_value}.to("the new value for the second one")
    end
  end

end