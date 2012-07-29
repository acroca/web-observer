require 'spec_helper'

describe Executor do
  describe "simple execution" do
    let(:content) { "<div>1</div><div>content</div><h1>3</h1>" }
    let(:css_selector) { "div:nth(2)" }
    let(:expected) { 'content' }
    let(:old_value) { 'old' } 

    let(:petition) { FactoryGirl.create(:petition,
      css_selector: css_selector, 
      last_value: old_value, 
      request_url: 'http://www.example.com/req', 
      callback_url: 'http://www.example.com/cb') }
    let(:response) { {:body => content} }
    let!(:request){ stub_http_request(:get, "http://www.example.com/req").to_return(response) }
    let!(:callback) { stub_http_request(:post, "http://www.example.com/cb").with(:body => expected) }
    let(:executor) { Executor.new }

    before do 
      executor.queue(petition)
    end  

    it "works" do
      executor.run
      request.should have_been_requested
      callback.should have_been_requested
    end
  
    it "sets the new value" do
      expect{
        executor.run
      }.to change{petition.reload.last_value}.to(expected)
    end

    context "when the old value is the same as the new value" do
      let(:old_value) { expected }
      it "doesn't call the callback" do
        request.should have_been_requested
        callback.should_not have_been_requested
      end
    end

    context "when the response is not 2xx" do
      let(:response) { {:status => 404} }
      it "doesn't call the callback" do
        executor.run
        request.should have_been_requested
        callback.should_not have_been_requested
      end
    end

    context "when the css query returns nothing" do
      let(:response) { {body: '<span>something</span>'} }
      let(:css_selector) { 'div' }
      
      it "doesn't call the callback" do
        executor.run
        request.should have_been_requested
        callback.should_not have_been_requested
      end
    end

    context "when the content is not parseable" do
      let(:response) { {body: '--------'} }
      
      it "doesn't call the callback" do
        executor.run
        request.should have_been_requested
        callback.should_not have_been_requested
      end
    end

  end

  it "executes multple items in queue" do
    petition_1 = FactoryGirl.create(:petition,
      callback_url: "http://www.example.com/1/cb", 
      request_url: "http://www.example.com/1/req",
      css_selector: 'div',
      last_value: 'old')
    petition_2 = FactoryGirl.create(:petition, 
      callback_url: "http://www.example.com/2/cb", 
      request_url: "http://www.example.com/2/req", 
      css_selector: 'span',
      last_value: 'old')
    r1 = stub_http_request(:get, "http://www.example.com/1/req").to_return(body: '<div>1</div>')
    r2 = stub_http_request(:get, "http://www.example.com/2/req").to_return(body: '<span>2</span>')
    c1 = stub_http_request(:post, "http://www.example.com/1/cb").with(:body => '1')
    c2 = stub_http_request(:post, "http://www.example.com/2/cb").with(:body => '2')

    executor = Executor.new
    executor.queue(petition_1)
    executor.queue(petition_2)
    executor.run

    r1.should have_been_requested
    r2.should have_been_requested
    c1.should have_been_requested
    c2.should have_been_requested
  end 

  describe ".process_batch" do
    it 'queues the petitions' do
      petition1 = FactoryGirl.create(:petition)
      petition2 = FactoryGirl.create(:petition)
      Petition.stub(:next_batch){ [petition1, petition2] }
      Executor.any_instance.should_receive(:queue).with(petition1)
      Executor.any_instance.should_receive(:queue).with(petition2)
      Executor.any_instance.should_receive(:run)

      Executor.process_batch
    end

    it 'updates the last_check' do
      petition = FactoryGirl.create(:petition)
      Petition.stub(:next_batch){ [petition] }
      Executor.any_instance.should_receive(:queue).with(petition)
      Executor.any_instance.should_receive(:run)
      expect{
        Executor.process_batch
      }.to change{petition.reload.last_check}
    end
  end
end