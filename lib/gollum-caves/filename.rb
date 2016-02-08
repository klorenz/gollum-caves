module GollumCaves
  module FileNameMixin
    # Public: Split a path into dir, name and format
    #
    # path - path of a file to split (without wikipart)
    #
    # Returns a tuple `[dir, name, format]`.
    def split_path(path)
      dir = File.dirname(path)
      name, format = Gollum::Page.parse_filename(File.basename(path))
      [dir, name, format]
    end
  end
end
