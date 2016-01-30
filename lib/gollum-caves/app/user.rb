module Valuable
  class App
    before do
      env = request.env

      if settings.gollum_caves[:auth_method] == 'apache-authnz-ldap'
        @user = GollumCaves::User(
          username = env['AUTHENTICATE_UID'],
          name     = env['AUTHENTICATE_CN'],
          mail     = env['AUTHENTICATE_MAIL'],
          roles    = env['AUTHENTICATE_OU'].split(';')
          )
      elsif settings.gollum_caves[:auth_method] == 'env'
        @user = GollumCaves::User(
          username = ENV['WIKI_USER_USERNAME'],
          name     = ENV['WIKI_USER_NAME'],
          mail     = ENV['WIKI_USER_MAIL'],
          roles    = ENV['WIKI_USER_ROLES'].split(/\s+|\s*;\s*|\s*,\s*/)
          )
      end

      session['gollum.author'] = @user.author
    end
  end
end
