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

    attr_reader :path
    attr_reader :wiki

    def format
      @format ||= unless as_page.nil?
        as_page.format
      else
        if extension == ''
          :text
        else
          extension.to_sym
        end
      end
    end

    def self.editor_for(thing)
      if thing.respond_to? 'editor'
        thing.editor
      else
        if thing.is_a? Symbol
          fmt = Gollum::Page.format_for("foo.#{thing}")
        else
          fmt = Gollum::Page.format_for(thing)
        end
        if fmt.nil?
          "editor_source"

        # somehow check if is_binary
        else
          "editor_#{fmt}"
        end
      end
    end

    def editor
      if is_binary?
        "editor_upload"
      else
        WikiFile.editor_for(@path)
      end
    end

    def content
      if page = as_page
        page.text_data
      else
        raw_data
      end
    end

    def extension
      @ext ||= File.extname(filename)
    end

    def dir
      File.dirname(@path)
    end

    def filename
      @filename ||= if as_page.nil?
        as_page.filename
      else
        @path
      end
    end

    def url_path
      make_url_path(@path)
      path = if @path.include?('/')
          @path.sub(/\/[^\/]+$/, '/')
        else
          ''
        end
      path << Gollum::Page.cname(name)
      path
    end

    def escaped_url_path
      CGI.escape(url_path).gsub('%2F', '/')
    end

    def name
      @name ||= if as_page.nil?
        as_page.name
      else
        File.basename(@path, extension)
      end
    end

    def update_metadata(opts)
      author   = opts[:author]
      message  = opts[:message]
      more_metadata = opts[:metadata]

      metadata.deep_merge more_metadata
      # write metadata using a writer depending on format
    end

    def method_missing(method, *args, &block)
      as_page.send(method, *args, &block)
    end

    def version
      @commit.id
    end

    def as_page
      @page ||= @tree_entry.page(@wiki, @commit)
    end

    def as_file
      @wiki.file(@path, version)
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

    def is_binary?
      raw_data =~ /\0/
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

      #check_path = "./#{path}"
      check_path = path
      log_debug "check_path: #{check_path}"

      if (tree_entry = map.detect { |entry| log_debug "entry.path #{entry.path}" ; entry.path == check_path })
        log_debug "Create wikifile for #{path}"
        WikiFile.new(wiki, path, tree_entry, commit)
      end
    end

  end
end
