# basics
require 'rack'
require 'rubygems'
require 'json'

require 'gollum-lib'
require 'gollum'
require 'gollum-caves/app'

# tweak gollum classes for handling multiple repos next to each other
require 'gollum-caves/file'
require 'gollum-caves/views/create'
require 'gollum-caves/views/latest_changes'
require 'gollum-caves/views/history'
require 'gollum-caves/views/page'
require 'gollum-caves/views/pages'
require 'gollum-caves/views/history'
require 'gollum-caves/views/edit'

require 'rack_dav'
require 'gollum-caves/dav'
