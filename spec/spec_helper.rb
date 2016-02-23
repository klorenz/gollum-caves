# spec/spec_helper.rb
require 'rack/test'
require 'rspec'


ENV['RACK_ENV'] = 'test'

require File.expand_path '../../lib/gollum-caves/rack_app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() Valuable::App end
end

# For RSpec 2.x and 3.x
RSpec.configure { |c| c.include RSpecMixin }
