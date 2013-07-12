require 'spec_helper'

describe "When testing against nginx process", type: :feature do
  before do
    Capybara.run_server = false
    Capybara.app_host = "http://localhost:4567"
    Capybara.current_driver = :webkit
  end

  context "GET /" do
    it "returns successfully" do
      visit '/'
      page.should have_content "Hello, World"
    end
  end

  context "GET /:name" do
    it "returns the name in the response" do
      visit '/JT'
      page.should have_content "Hello, JT"
    end
  end

  context "GET /age/:age" do
    it "returns the age in the response" do
      visit '/age/30'
      page.should have_content "You are 30 years old."
    end
  end
end
