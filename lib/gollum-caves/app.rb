require 'gollum/app'

if ENV['WIKI_ROOT'].nil?
   ENV['WIKI_ROOT'] = File::expand_path("../../wiki", __FILE__)
end

require 'logger'
$LOG = Logger.new(ENV.fetch('WIKI_LOG_FILE', STDERR), 'daily')

# module GollumCaves
#   class App < Sinatra::Base
#     register Mustache::Sinatra
#     include Precious::Helpers
#
#     dir = File.dirname(File.expand_path(__FILE__))
#
#
#
#     before do
#       @public_dir     = File.expand_path("../../../public", __FILE__)
#       @wiki_root      = ENV['WIKI_ROOT'] || File.expand_path("../../..", __FILE__)
#       @default_coll, @default_wiki = ENV.fetch('WIKI_DEFAULT', "wiki/me").split('/')
#       @meta_wiki_name = ENV['WIKI_META_WIKI_NAME'] || 'me'
#     end
#



module Valuable
  # Valuable::App is derived from gollum's Precious::App
  #
  # It extends and overrides many methods from it.
  class App < Precious::App

    # before do
    #   puts '[Params]'
    #   p params
    # end

    before do
      @public_dir     = File.expand_path("../../../public", __FILE__)
      @wiki_root      = ENV['WIKI_ROOT'] || File.expand_path("../../..", __FILE__)
      @default_coll, @default_wiki = ENV.fetch('WIKI_DEFAULT', "wiki/me").split('/')
      @meta_wiki_name = ENV['WIKI_META_WIKI_NAME'] || 'me'
    end

    get '/bootstrap/*' do
      file_name = File.join(@public_dir, request.path_info)
      send_file file_name
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

plugin_dir = ::File.join(ENV['WIKI_ROOT'], 'wiki-plugins')

Dir.foreach(plugin_dir) do |item|
  next if item == '.' or item == '..'
  Dir.foreach(File.join(plugin_dir, item)) do |file|
    next if file == '.' or item == '..'
    if file == "config.rb"
      require File.join(plugin_dir, item, "config.rb")
    end
  end
end
