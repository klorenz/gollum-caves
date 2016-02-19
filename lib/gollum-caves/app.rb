# ~*~ encoding: utf-8 ~*~
require 'cgi'
require 'sinatra'
require 'mustache/sinatra'
require 'useragent'
require 'stringex'

require 'gollum/views/layout'
require 'gollum/views/editable'
require 'gollum/views/has_page'
require 'gollum/helpers'
require 'gollum-caves/logging'

require 'gollum-caves/views/page'

if ENV['WIKI_ROOT'].nil?
   ENV['WIKI_ROOT'] = File::expand_path("../../../wiki", __FILE__)
end

# require 'logger'
# $LOG = Logger.new(ENV.fetch('WIKI_LOG_FILE', STDERR), 'daily')

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

module Precious
  class App < Sinatra::Base
    register Mustache::Sinatra
    include Precious::Helpers
    include GollumCaves::Logging

    dir     = File.expand_path("../../..", __FILE__)
    puts "dir: #{dir}"

    # Detect unsupported browsers.
    Browser = Struct.new(:browser, :version)

    @@min_ua = [
        Browser.new('Internet Explorer', '10.0'),
        Browser.new('Chrome', '7.0'),
        Browser.new('Firefox', '4.0'),
    ]

    def supported_useragent?(user_agent)
      ua = UserAgent.parse(user_agent)
      @@min_ua.detect { |min| ua >= min }
    end

    # We want to serve public assets for now
    set :public_folder, "#{dir}/public/gollum-caves"
    set :static, true
    set :default_markup, :markdown

    set :mustache, {
        # Tell mustache where the Views constant lives
        :namespace => Precious,

        # Mustache templates live here
        :templates => "#{dir}/templates",

        # Tell mustache where the views are
        :views     => "#{dir}/views"
    }

    # Sinatra error handling
    configure :development, :staging do
      enable :show_exceptions, :dump_errors
      disable :raise_errors, :clean_trace

      $LOG = Logger.new(STDOUT)
      $LOG.level = Logger::DEBUG
    end

    configure :production do
      Dir.mkdir('logs') unless File.exist?('logs')
      $LOG = Logger.new('logs/common.log','weekly')
      $LOG.level = Logger::WARN
    end

    configure :test do
      enable :logging, :raise_errors, :dump_errors
    end

    before do
      settings.wiki_options[:allow_editing] = settings.wiki_options.fetch(:allow_editing, true)
      @allow_editing = settings.wiki_options[:allow_editing]
      forbid unless @allow_editing || request.request_method == "GET"

      #Precious::App.set(:mustache, { :templates => settings.gollum_caves[:template_path]})

      @base_url = url('/', false).chomp('/')
      @page_dir = settings.wiki_options[:page_file_dir].to_s
      # above will detect base_path when it's used with map in a config.ru
      settings.wiki_options.merge!({ :base_path => @base_url })
      @css = settings.wiki_options[:css]
      @js  = settings.wiki_options[:js]
      @mathjax_config = settings.wiki_options[:mathjax_config]

    #  wiki_dir = settings.wiki_options.fetch(:wiki, File.expand_path("wiki"))
      wiki_dir = settings.gollum_caves.fetch(:wiki_root, File.expand_path("wiki"))

      @wm = GollumCaves::WikiManager.new(wiki_dir)
      @wm.init()

      log_debug("path_info: #{request.path_info}")
    end

        private

    # Options parameter to Gollum::Committer#initialize
    #     :message   - The String commit message.
    #     :name      - The String author full name.
    #     :email     - The String email address.
    # message is sourced from the incoming request parameters
    # author details are sourced from the session, to be populated by rack middleware ahead of us
    def commit_message
      msg               = (params[:message].nil? or params[:message].empty?) ? "[no message]" : params[:message]
      commit_message    = { :message => msg }
      author_parameters = session['gollum.author']
      commit_message.merge! author_parameters unless author_parameters.nil?
      commit_message
    end

    def find_upload_dest(path)
      settings.wiki_options[:allow_uploads] ?
          (settings.wiki_options[:per_page_uploads] ?
              "#{path}/#{@name}".sub(/^\/\//, '') : 'uploads'
          ) : ''
    end


  end
end


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
    #   @wiki_root      = ENV['WIKI_ROOT'] || File.expand_path("../../..", __FILE__)
    #   @default_coll, @default_wiki = ENV.fetch('WIKI_DEFAULT', "wiki/about").split('/')
    #   @meta_wiki_name = ENV['WIKI_META_WIKI_NAME'] || 'about'
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
require 'gollum-caves/app/user'
require 'gollum-caves/app/create'
require 'gollum-caves/app/edit'
require 'gollum-caves/app/routes'

require 'gollum-caves/config'
require 'gollum-caves/bootstrap'

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

dir = File.expand_path("../../..", __FILE__)
Precious::App.settings.gollum_caves[:template_path].push("#{dir}/templates")
