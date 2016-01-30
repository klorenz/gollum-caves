require 'gollum-caves/logging'

module GollumCaves
  class WikiFile
    include GollumCaves::FileNameMixin
    include GollumCaves::Logging

    def initialize(wiki, path, tree_entry, commit)
      @wiki = wiki
      @path = path
      @tree_entry = tree_entry
      @commit = commit
      @blob = tree_entry.blob(@wiki.repo)
    end

    def version
      @commit.id
    end

    def raw_data()
      if @blob.is_symlink
        log_debug @blob.symlink_target('.')
      end
      # if !@wiki.repo.bare && @blob.is_symlink
      #   new_path = @blob.symlink_target(::File.join(@wiki.repo.path, '..', self.path))
      #   return IO.read(new_path) if new_path
      # end

      log_debug "raw_data #{@blob.data}"

      @blob.data
    end

    # Public: Class method to find a path in wiki and return corresponding WikiFile object
    #
    def self.find(wiki, path, version = nil, try_on_disk = false)
      version = version.nil? ? wiki.latest_version : version
      log_debug "wiki #{wiki}"
      log_debug "version #{version}"
      log_debug "path #{path}"
      commit = wiki.commit_for(version)
      map = wiki.tree_map_for(version)

      log_debug "map #{map}"

      log_debug path

      check_path = "./#{path}"
      log_debug "check_path: #{check_path}"

      if (tree_entry = map.detect { |entry| log_debug "entry.path #{entry.path}" ; entry.path == check_path })
        log_debug "Create wikifile for #{path}"
        WikiFile.new(wiki, path, tree_entry, commit)
      end
    end

  end
end
