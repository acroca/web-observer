require 'factory_girl'

FactoryGirl.define do
  factory :petition do
    request_url 'http://www.example.com/request'
    css_selector 'h1:first'
    callback_url 'http://www.example.com/callback'
  end
end