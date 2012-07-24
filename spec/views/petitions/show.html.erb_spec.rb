require 'spec_helper'

describe "petitions/show" do
  before(:each) do
    @petition = assign(:petition, stub_model(Petition,
      :request_url => "Request Url",
      :css_selector => "Css Selector",
      :callback_url => "Callback Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Request Url/)
    rendered.should match(/Css Selector/)
    rendered.should match(/Callback Url/)
  end
end
