module GollumCaves
  module FileNameMixin
    # Public: Split a path into dir, name and format
    #
    # path - path of a file to split (without wikipart)
    #
    # Returns a tuple `[dir, name, format]`.
    def split_path(path)
      ext = File.extname(path)
      dir = File.dirname(path)
      name = File.basename(path, ext)

      format = case ext
        when ".md"
          :markdown
        else
          ext[1..-1].to_sym
        end

      [dir, name, format]
    end
  end
end
