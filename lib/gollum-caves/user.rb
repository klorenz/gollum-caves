module GollumCaves
  class User
    initialize(username, name, mail, roles)
      @username = usernanme
      @name = name
      @mail = mail
      @roles = roles
    end

    # Public: return
    def author
      {
        :name => @name
        :mail => @mail
      }
    end
  end
end
