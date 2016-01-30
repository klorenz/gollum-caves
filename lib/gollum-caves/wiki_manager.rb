require 'gollum/helpers'
require 'gollum-caves/filename'
require 'gollum-caves/wiki_settings'
require 'gollum-caves/wiki'
require 'gollum-caves/logging'
require 'grit_adapter/git_layer_grit'

# TODO: create cache for wiki settings

module GollumCaves
  class CollectionDoesNotExist < RuntimeError
  end

  class WikiManager
    include Precious::Helpers
    include GollumCaves::FileNameMixin
    include GollumCaves::Logging

    attr_reader :settings
    attr_reader :settings_page_path

    # Public: Initialize a new WikiManager
    #
    # path    - The String path to the folder, which shall contain
    #           collections.
    # options - Optional Hash:
    #           :meta_wiki_name    - Name of meta wiki in a collections.  This
    #                                stores information about collection and
    #                                can contain pages to configure other wikis.
    #           :main_coll_name    - Collection containing the meta wiki
    #           :default_wiki_name - default wikiname, if no wikiname
    #                                given
    #           :default_coll_name - default collection, if no collection
    #                                given
    #
    # Returns a GollumCaves::WikiManager
    def initialize(rootpath, opts={})
      @root = rootpath
      @wiki_cache = {}
      initialize_attrs read_farm_settings.merge(opts)
      @settings = GollumCaves::WikiSettings.new(self)
    end

    def [](key)
      c, w = key.split('/')
      wiki(c,w)
    end

    # Public: Initialize a root dir with current settings
    def init(override_settings: false)
      farm_settings = File.join(@root, "settings.yml")

      write_settings = true

      if File.exist? farm_settings and not override_settings
        initialize_attrs YAML.load File.read(farm_settings)
        write_settings = false
      end

      if not exists_collection? @main_coll_name
        create_collection(@main_coll_name)
      end

      if not exists_collection? "wiki-plugins"
        create_collection("wiki-plugins", bare: false)
      end

      if not exists_collection? @default_coll
        create_collection(@default_coll)
      end

      if not exists? @default_wiki
        create_wiki(@default_coll, @default_wiki)
      end

      write_farm_settings if write_settings
    end

    # Public: Return default landing page for given collection and wikiname
    #
    # collection - Optional String name of collection
    # wikiname   - Optional String name of wiki
    # page_dir   - Optional Directory in wiki, where pages are located.
    def get_default_page(collection=nil, wikiname=nil, page_dir=nil)
      collection ||= @default_coll
      wikiname   ||= @default_wiki
      page_dir = page_dir.to_s
      index_page = wiki(collection, wikiname).index_page
      clean_url [collection, wikiname, page_dir, index_page].join "/"
    end

    # def page_url(collection=nil, wikiname=nil, page_dir=nil, page=nil, wiki=nil)
    #   if wiki.nil?
    #     collection ||= @default_coll
    #     wikiname   ||= @default_wiki
    #     page_dir   = page_dir.to_s
    #     w = wiki(collection, wikiname)
    #
    #   page = ||=
    #   url = [wiki(colleciton, wikiname).base_path

    def create_collection(name, template: nil, bare: nil)
      unless exists_collection? name
        create_wiki(name, @meta_wiki_name, {
          :bare => bare,
          :assert_valid_collection => false,
        })
      else
        true
      end
    end

    def exists_collection?(name)
      exists?("#{name}/#{@meta_wiki_name}")
    end

    def exists?(name)
      # we could raise here an exception if name not matches collection/wiki
      return true if File.directory?("#{@root}/#{name}.git")
      return true if File.directory?("#{@root}/#{name}/.git")
      return false
    end

    # assuming it exists
    def is_bare?(name)
      File.directory?("#{@root}/#{name}.git")
    end

    def meta_wiki(opts={})
      wiki(@main_coll_name, @meta_wiki_name, opts)
    end

    def get_coll_wiki_names(collection = nil, name = nil)
      if name.nil?
        if collection.nil?
          collection ||= @default_coll
          name       ||= @default_wiki
        else
          if collection[0] == "/"
            collection = collection[1..-1]
          end
          if collection.include? "/"
            collection, name = collection.split('/')
          else
            name = @meta_wiki_name
          end
        end
      end
      [collection, name]
    end

    def wiki(collection=nil, name=nil, opts=nil)
      collection, name = get_coll_wiki_names(collection, name)
      wikipath = "#{collection}/#{name}"

      if @wiki_cache.has_key? wikipath
        return @wiki_cache[wikipath]
      end

      options = {}
      if not opts.nil?
        options = options.merge(opts)
      end

      if File.directory?("#{@root}/#{wikipath}.git")
        repo_path = "#{@root}/#{wikipath}.git"
        options[:repo_is_bare] = true
      else
        repo_path = "#{@root}/#{wikipath}"
        options[:repo_is_bare] = false
      end

      options = options.merge({ :base_path => "/#{wikipath}"})

      gollum_wiki = Gollum::Wiki.new(repo_path, options)

      @wiki_cache[wikipath] = Wiki.new(self, gollum_wiki, collection, name)
    end

    # TODO: Do this with Gollum::Repo.init_bare() and ...init()

    def create_wiki(collection, wiki=nil, opts={})
      collection, wiki = get_coll_wiki_names(collection, wiki)

      bare     = opts.fetch(:bare, @is_bare)
      template = opts[:template]

      if opts.fetch(:assert_valid_collection, true)
        unless exists_collection? collection
          raise CollectionDoesNotExist, "Collection #{collection} does not exist."
        end
      end
      # extra_args += " --bare" if bare
      #
      # puts `git init #{extra_args} "#{@root}/#{repo_name}" #{extra_args} 2>&1`
      # $?.exitstatus == 0
      #
      if bare
        Gollum::Git::Repo.init_bare("#{@root}/#{collection}/#{wiki}.git")
      else
        Gollum::Git::Repo.init("#{@root}/#{collection}/#{wiki}")
      end
      wiki(collection, wiki)
    end

    # Public: clone a wiki from a collection/wiki to a user/wiki
    #
    # returns true on success
    def fork_wiki(source, destination)
      # TODO: consider --bare
      `git clone "#{@root}/#{source}" "#{@root}/#{destination}"`
      $?.exitstatus == 0
    end

    def clone_wiki(source, destination)
      `git clone "#{source}" "#{@root}/#{destination}"`
      $?.exitstatus == 0
    end

    # Public: expand path into collection, wikiname and path
    def split_wiki_path(path)
      if path == "/"
        cn, wn, pn = @default_coll, @default_wiki, "/"
      else
        path = path[1..-1] if path[0] == '/'

        cn, wn, pn = path.split('/', 3)
        pn = '/' if pn.nil? or pn.empty?
#        pn = '/'+pn if pn[0] != '/'
        wn = @default_wiki if wn.nil? or wn.empty?
      end
      [ cn, wn, pn ]
    end

    # Public: expand path into wikipath and path
    #
    # wikipath is `<collection>/<path>`
    def split_wiki_path_wp(path)
      cn, wn, pn = split_wiki_path path
      ["#{cn}/#{wn}", pn]
    end

    # def list_all_files(wiki, version = nil)
    #   if version.nil?
    #   commit = wiki.commit_for(ref)
    #   if (sha = @access.ref_to_sha(ref))
    #     commit = @access.commit(sha)
    #     tree_map_for(sha).inject([]) do |list, entry|
    #       next list unless @page_class.valid_page_name?(entry.name)
    #       list << entry.page(self, commit)
    #     end
    #   else
    #     []
    #   end
    #
    #
    #   tree_map_for(sha).inject([]) do |list, entry|
    #     next list unless @page_class.valid_page_name?(entry.name)
    #       list << entry.page(self, commit)
    #     end
    #
    # end


    private

    def initialize_attrs(opts)
      @meta_wiki_name   = opts.fetch :meta_wiki_name,     "me"
      @main_coll_name   = opts.fetch :main_coll_name,     "wiki"
      @default_coll     = opts.fetch :default_coll_name,  "wiki"
      @default_wiki     = opts.fetch :default_wiki_name,  @meta_wiki_name
      @plugin_coll_name = opts.fetch :plugin_coll_name,   "wiki-plugins"
      @settings_page_path = opts.fetch :settings_page_path, "Settings.md"
      @is_bare            = opts.fetch :use_bare_repos,     false
    end

    def read_default_farm_settings()
      default_farm_settings = File.expand_path(
        "../../../samples/wikiroot-settings.yml",
        __FILE__)

      YAML.load File.read(default_farm_settings)
    end


    def read_farm_settings()
      farm_settings = File.join(@root, "settings.yml")

      if File.exist? farm_settings and not override_settings
        settings = YAML.load File.read(farm_settings)
      else
        settings = read_default_farm_settings
      end

      opts = {}

      settings.each do |key,value|
        if value.is_a? Hash
          opts[key] = value[:value]
        else
          opts[key] = value
        end
      end

      return opts
    end

    def write_farm_settings()
      default_farm_settings = read_default_farm_settings

      farm_settings_file = File.join(@root, "settings.yml")

      current_settings = ( File.exist?(farm_settings_file) ?
          YAML.load(File.read(farm_settings_file)) : {} )

      settings = default_farm_settings.merge current_settings
      settings['meta_wiki_name']['value']     = @meta_wiki_name
      settings['main_coll_name']['value']     = @main_coll_name
      settings['default_wiki_name']['value']  = @default_wiki
      settings['default_coll_name']['value']  = @default_coll
      settings['plugin_coll_name']['value']   = @plugin_coll_name
      settings['settings_page_path']['value'] = @settings_page_path
      settings['use_bare_repos']['value']     = @is_bare

      File.write farm_settings_file, YAML.dump(settings)
    end
  end
end
