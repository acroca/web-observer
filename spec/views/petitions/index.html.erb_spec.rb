require 'spec_helper'

describe "petitions/index" do
  before(:each) do
    assign(:petitions, [
      stub_model(Petition,
        :request_url => "Request Url",
        :css_selector => "Css Selector",
        :callback_url => "Callback Url"
      ),
      stub_model(Petition,
        :request_url => "Request Url",
        :css_selector => "Css Selector",
        :callback_url => "Callback Url"
      )
    ])
  end

  it "renders a list of petitions" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Request Url".to_s, :count => 2
    assert_select "tr>td", :text => "Css Selector".to_s, :count => 2
    assert_select "tr>td", :text => "Callback Url".to_s, :count => 2
  end
end
