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
$GOLLUM_PATH = File.expand_path( ENV['WIKI_REPO'] || "#{File.dirname(__FILE__)}/wiki" )

Precious::App.set(:gollum_path, $GOLLUM_PATH)

$APP_ROOT = File.expand_path "../../"

# include gollum configurations
require 'gollum-caves/config'
require 'gollum-caves/app'

# run app
map "/wiki" do
  run Valuable::App
end

require 'rack_dav'
require 'gollum-caves/dav'

map '/dav' do
  run RackDAV::Handler.new(:resource_class => GollumCaves::GitDavResource)
end
