require 'gollum-caves/user'

module Precious
  class App
    before do
      env = request.env

      if settings.gollum_caves[:auth_method] == 'apache-authnz-ldap'
        @user = GollumCaves::User.new(
          username: env['AUTHENTICATE_UID'],
          name:     env['AUTHENTICATE_CN'],
          mail:     env['AUTHENTICATE_MAIL'],
          roles:    env['AUTHENTICATE_OU'].split(';')
          )
      elsif settings.gollum_caves[:auth_method] == 'env'
        @user = GollumCaves::User.new(
          username: ENV['WIKI_USER_USERNAME'],
          name:     ENV['WIKI_USER_NAME'],
          mail:     ENV['WIKI_USER_MAIL'],
          roles:    ENV.fetch('WIKI_USER_ROLES', '').split(/\s+|\s*;\s*|\s*,\s*/)
          )
      elsif ['basic'].include? settings.gollum_caves[:auth_method]
        @user = GollumCaves::User.new(
          username: env['AUTHENTICATE_UID'],
          name:     env['AUTHENTICATE_CN'],
          mail:     env['AUTHENTICATE_MAIL'],
          roles:    env['AUTHENTICATE_OU'].split(';')
          )
      else
        @user = GollumCaves::User.new(
          username: "anonymous",
          name:     "An Anonymous User",
          mail:     "anon@anon.tld",
          roles:    [],
          )
      end

      log_debug "author: #{@user.author} (username=#{@user.username})"

      session['gollum.author'] = @user.author
    end
  end
end
