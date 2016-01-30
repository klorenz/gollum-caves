$LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), 'lib'))

require 'gollum-caves/rack_app'
require 'rack/urlmap'

# run Rack::URLMap.new({
#   "/wiki" => Valuable::App.new,
#   "/dav"  => RackDAV::Handler.new(:resource_class => GollumCaves::GitDavResource),
#   "/"     => Proc.new { |env| [302, {'Location' => '/wiki/'}, []] },
# })

map "/wiki" do
  run Valuable::App
end

map "/dav" do
  run RackDAV::Handler.new(:resource_class => GollumCaves::GitDavResource)
end

map "/" do
  run Proc.new { |env| [302, {'Location' => '/wiki/'}, []] }
end
