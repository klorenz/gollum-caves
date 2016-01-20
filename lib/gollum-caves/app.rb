require 'gollum/app'

module Valuable
  # Valuable::App is derived from gollum's Precious::App
  #
  # It extends and overrides many methods from it.
  class App < Precious::App
    before do
      @public_dir = File.expand_path("../../../public", __FILE__)
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

plugin_dir = File.join($GOLLUM_PATH, 'wiki-plugins')

Dir.foreach(plugin_dir) do |item|
  next if item == '.' or item == '..'
  Dir.foreach(File.join(plugin_dir, item)) do |file|
    next if file == '.' or item == '..'
    if file == "config.rb"
      require File.join(plugin_dir, item, "config.rb")
    end
  end
end
