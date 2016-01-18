$LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), 'lib'))

# basics
require 'rack'
require 'rubygems'
require 'json'

require 'gollum/app'

# tweak gollum classes for handling multiple repos next to each other
require 'gollum-caves/file'
require 'gollum-caves/views/create'
require 'gollum-caves/views/latest_changes'
require 'gollum-caves/views/history'
require 'gollum-caves/views/page'
require 'gollum-caves/views/pages'
require 'gollum-caves/views/history'
require 'gollum-caves/views/edit'

# set gollum base path, which is the root for wiki collections
gollum_path = File.expand_path( ENV['WIKI_REPO'] || "#{File.dirname(__FILE__)}/wiki" )
Precious::App.set(:gollum_path, gollum_path)

# include gollum configurations
require 'gollum-caves/config'

# go with rack for ease of deployment to browser and locally
require 'rack'

module Valuable
  # Valuable::App is derived from gollum's Precious::App
  #
  # It extends and overrides many methods from it.
  class App < Precious::App
    before do
      @public_dir = File.join(File.dirname(File.expand_path(__FILE__)), 'public')
    end

    get '/gollum-caves/css/*' do
      file_name = File.join(@public_dir, request.path_info)
      send_file file_name
    end

    get '/gollum-caves/javascript/*' do
      puts "here javascript"
      file_name = File.join(@public_dir, request.path_info)
      send_file file_name
    end
  end
end

# build sinatra app for rack
require 'gollum-caves/app/base'
require 'gollum-caves/app/routes'

plugin_dir = File.join(File.dirname(__FILE__), 'wiki', 'wiki-plugins')

Dir.foreach(plugin_dir) do |item|
  next if item == '.' or item == '..'
  Dir.foreach(File.join(plugin_dir, item)) do |file|
    next if file == '.' or item == '..'
    if file == "config.rb"
      require File.join(plugin_dir, item, "config.rb")
    end
  end
end

# run app
run Valuable::App
