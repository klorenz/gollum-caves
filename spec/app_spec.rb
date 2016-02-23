require File.expand_path "../spec_helper.rb", __FILE__

describe "Gollum Caves" do

  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end

  # it "should allow accessing the home page" do
  #   get '/'
  #   expect(last_response).to be_ok
  # end
end

# http://chuckvose.com/tech/2015/01/06/testing-rack-middleware-in-request-specs.html

# Ensure that the config.ru gets loaded before these tests
#let(:app) {
#  Rack::Builder.new do
#    eval File.read(Rails.root.join('config.ru'))
#  end
#}
