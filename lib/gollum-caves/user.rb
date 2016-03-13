module GollumCaves
  class User
    attr_reader :username
    attr_reader :name
    attr_reader :mail
    attr_reader :roles

    def groups
      @roles
    end

    def initialize(username: nil, name: nil, mail: nil, roles: nil)
      @username = username
      @name = name
      @mail = mail
      @roles = roles
    end

    # Public: return
    def author
      {
        :name => @name,
        :mail => @mail,
      }
    end
  end
end
