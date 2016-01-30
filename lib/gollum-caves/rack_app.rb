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

if ENV['WIKI_ROOT'].nil?
   ENV['WIKI_ROOT'] = File::expand_path("../../../wiki", __FILE__)
end

if ENV['WIKI_META_WIKI_NAME'].nil?
  ENV['WIKI_META_WIKI_NAME'] = "me"
end

Precious::App.set(:gollum_caves, {
  # :auth_method => # 'apache-authnz-ldap' # 'env' for local
  :auth_method => 'env',
  :wiki_root   => ENV['WIKI_ROOT']
})

# DEPRECATED: remove the use of this option
Precious::App.set(:gollum_path, ENV['WIKI_ROOT'])

# include gollum configurations
require 'gollum-caves/config'
require 'gollum-caves/app'

require 'rack_dav'
require 'gollum-caves/dav'
