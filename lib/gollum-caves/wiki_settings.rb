require 'gollum-caves/frontmatter'
require 'gollum-caves/logging'

module GollumCaves
  class WikiSettings
    @@cache = {}

    include GollumCaves::Frontmatter
    include Precious::Helpers
    include GollumCaves::Logging

    def initialize(wm)
      @wm = wm
      @log = $LOG
    end

    # Public: Read settings from wiki
    #
    # wiki    - wiki object to read settings from
    # path    - file to read settings from (optional, defaults to
    #           settings_page_path)
    # version - optional version to read settings from
    #
    def read(wiki, path = nil, version = nil)
      log_debug "read: wiki=#{wiki}, path=#{path}, version=#{version}"
      path ||= @wm.settings_page_path
      wikifile = wiki.wikifile(path, version)

      if wikifile.nil?
        log_debug "wikifile is nil"
        return {}
      end

      key = clean_path("#{wiki.base_path}/#{path}/#{wikifile.version}")

      log_debug "key: #{key}"
      if not @@cache.has_key? key
        data = case File.extname(path)
          when ".md"
            get_frontmatter wikifile.raw_data
          when ".json"
            JSON.parse wikifile.raw_data
          when ".yml", ".yaml"
            YAML.load wikifile.raw_data
          else
            {}
          end

        @@cache[key] = {
          :last_access => Time.now(),
          :settings => data,
        }
      end

      # TODO: cache has to be cleaned up after a while
      # store last access time?
      @@cache[key][:last_access] = Time.now()
      @@cache[key][:settings]
    end

    # Public: Write settings to wiki
    #
    # wiki    - wiki object to read settings from
    # path    - file to read settings from (optional, defaults to
    #           settings_page_name)
    # version - optional version of the current settings set, which shall be
    #           updated
    # settings - settings to write
    #
    def write(wiki, path = nil, version = nil, settings: nil,
      author: nil, message: nil)
      path ||= @wm.settings_page_path

      data = case File.extname(path)
        when ".md"
          wikifile = wiki.wikifile(path)
          raw_data = wikifile.nil? ? "" : wikifile.raw_data
          set_frontmatter(settings, raw_data)
        when ".json"
          JSON.generate settings
        when ".yml", ".yaml"
          YAML.dump settings
        else
          raise "cannot generate data for #{file}"
        end
      log_debug "write"
      log_debug "  settings: #{settings}"
      log_debug "  path: #{path}"
      log_debug "  data: #{data}"

      wiki.commit_files(
        author: author,
        message: message,
        files: {path => data}
      )

    end

    # Get Settings
    #
    # coll   - name of collection
    # wiki   - name of wiki
    # path   - path of page
    # policy - :wiki means wiki overrides coll overrides meta
    #          :coll means coll overrides meta
    #          :meta means meta overrides coll overrides wiki overrides page
    #          :page means page overrides wiki overrides coll overrides meta
    # version - TODO depending on policy this refers to corresponding wiki
    #           extract date and find version for this date for other wikis
    #
    def get(collname = nil, wikiname = nil, path = nil, policy = :wiki, version = nil, page_key = nil)
      unless version.nil?
        commit = @wm.wiki(collname, wikiname).commit_for(version)
      else
        commit = @wm.wiki(collname, wikiname).log(:max_count => 1)[0]
      end
      page_version = commit.id
      wiki_version = commit.id
      date = commit.authored_date
      meta_wiki_version = @wm.meta_wiki.log(:max_count => 1, :until => date)[0].id
      coll_version = @wm.wiki(collname).log(:max_count => 1, :until => date)[0].id

      meta_wiki_settings = read(@wm.meta_wiki, nil, meta_wiki_version)
      coll_settings      = read(@wm.wiki(collname), nil, coll_version)
      page_settings = nil
      wiki_settings = nil

      unless policy == :coll
        wiki_settings = read(@wm.wiki(collname, wikiname), nil, wiki_version)
      end

      unless policy == :coll or policy == :wiki
        page_settings      = {}
        unless path.nil?
          page_settings = read(@wm.wiki(coll, wiki), path, page_version)
        end
      end

      log_debug "meta_wiki_settings: #{meta_wiki_settings}"
      log_debug "coll_settings: #{coll_settings}"
      log_debug "wiki_settings: #{wiki_settings}"
      log_debug "page_settings: #{page_settings}"

      case policy
      when :wiki
        result = {}.deep_merge(meta_wiki_settings).deep_merge(coll_settings)
        result.deep_merge(wiki_settings)
      when :coll
        {}.deep_merge(meta_wiki_settings).deep_merge(coll_settings)
      when :meta
        result = {}.deep_merge(page_settings).deep_merge(wiki_settings)
        result.deep_merge(coll_settings).deep_merge(meta_wiki_settings)
      when :page
        result = {}.deep_merge(meta_wiki_settings).deep_merge(coll_settings)
        result.deep_merge(wiki_settings).deep_merge(page_settings)
      else
        raise ArgumentError, "Unknown policy #{policy}.  Use :wiki or :meta"
      end
    end

  end
end
