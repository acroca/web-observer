require 'spec_helper'

describe "petitions/edit" do
  before(:each) do
    @petition = assign(:petition, stub_model(Petition,
      :request_url => "MyString",
      :css_selector => "MyString",
      :callback_url => "MyString"
    ))
  end

  it "renders the edit petition form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => petitions_path(@petition), :method => "post" do
      assert_select "input#petition_request_url", :name => "petition[request_url]"
      assert_select "input#petition_css_selector", :name => "petition[css_selector]"
      assert_select "input#petition_callback_url", :name => "petition[callback_url]"
    end
  end
end
