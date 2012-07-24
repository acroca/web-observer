require 'spec_helper'

describe "petitions/new" do
  before(:each) do
    assign(:petition, stub_model(Petition,
      :request_url => "MyString",
      :css_selector => "MyString",
      :callback_url => "MyString"
    ).as_new_record)
  end

  it "renders new petition form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => petitions_path, :method => "post" do
      assert_select "input#petition_request_url", :name => "petition[request_url]"
      assert_select "input#petition_css_selector", :name => "petition[css_selector]"
      assert_select "input#petition_callback_url", :name => "petition[callback_url]"
    end
  end
end
