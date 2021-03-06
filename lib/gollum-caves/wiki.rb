require 'gollum-caves/wikifile'
require 'gollum-caves/logging'
require 'grit_adapter/git_layer_grit'

module GollumCaves
  class Wiki
    include GollumCaves::FileNameMixin
    include GollumCaves::Logging

    def initialize(wiki_manager, wiki, collname, wikiname)
      @wiki_manager = wiki_manager
      @collname     = collname
      @wikiname     = wikiname
      @wikipath     = "#{collname}/#{wikiname}"
      @wiki         = wiki
    end

    attr_reader :collname
    attr_reader :wikiname
    attr_reader :wikipath
    attr_reader :wiki_manager
    attr_reader :wiki

    def method_missing(method, *args, &block)
      @wiki.send(method, *args, &block)
    end

    # Public: return latest commit
    def latest_commit()
      commits = @wiki.log({:max_count => 1})
      return nil if commits.nil?
      return nil if commits.empty?
      return commits.first
    end

    def latest_sha()
      result = latest_commit
      return nil if result.nil?
      result.id
    end

    def latest_version()
      latest_sha
    end

    def list_tree(version=nil)
    end

    # Public: get file object
    #
    # other than gollum this method makes no difference between pages and
    # non-pages.  So this will return an object for anything - page or file in
    # gollum terms.
    #
    def wikifile(path, version=nil)
      log_info "wikifile: #{path}, #{version}"
      path = Gollum::Page.cname(path)

      ext = File::extname(path)
      if ext == ''
        name = File.basename(path)
        dir  = File.dirname(path)

        if page = @wiki.paged(name, dir, version)
          WikiFile.find(self, page.filename, version)
        else
          WikiFile.path = path+'.md'
        end
      else
        WikiFile.find(self, path, version)
      end
    end

    def wikifile_exists?(path, version=nil)
      not WikiFile.find(self, path, version).nil?
    end

    def commit_for(version)
      version.is_a?(Gollum::Git::Commit) ? version : @wiki.commit_for(version)
    end

    def normalize(data)
      data.gsub("\r", '')
    end

    # author - Hash:
    #          name  - name of Author
    #          email - email of Author
    # message - commit message
    # parent  - version spec
    # files   - Hash:
    #             <path> -> <content>
    def commit_files(author: nil, message: nil, parent: nil, files: {})
      # check parameters
      raise "no author given"  if author.nil?
      raise "no message given" if message.nil?

      # get parent commit
      if not parent.nil?
        parent = @wiki.commit_for(parent)
      elsif parent.nil? and not @wiki.repo.head.commit.nil?
        parent = @wiki.commit_for(@wiki.repo.head.commit.id)
      end

      unless parent.nil?
        log_debug "    checkpoint (parent #{parent})"
        if parent.id != @wiki.repo.head.commit.id
          log_debug "   (parent #{parent} is not head)"

          # now check version of each file individually, if it has been
          # changed in one of the changes since parent.
          #
          # if so, raise error, else proceed

          files.each do |path,contents|
            next if @wiki.repo.log(nil, path, {:since => parent.authored_date}).empty?
            log_debug "    file has changed"
            raise "repo has changed"
          end
        end
      end

      options = {
        :message => message,
        :author  => author,
      }
      unless parent.nil?
        options[:parent] = parent
      end

      committer = Gollum::Committer.new(@wiki, options)

      files.each do |path,contents|
        path = path.dup.gsub(/^\.\//, '')
        if contents.nil?
          committer.index.delete(path)
        else
          committer.index.add(path, normalize(contents))
        end
        # if wikifile_exists? path, parent
        #   log_debug "    U path: #{path}, contents: #{normalize(contents)}"
        #   committer.index.add(path.dup, normalize(contents))
        # else
        #   log_debug "    A path: #{path}, contents: #{normalize(contents)}"
        #   dir, name, format = split_path path
        #   committer.add_to_index(dir, name, format, contents)
        # end
      end

      committer.after_commit do |index, sha|
        log_debug "  after_commit: #{index}, #{sha}"
        @wiki.clear_cache

        files.each do |path,contents|
          path = path.gsub(/^\.\//, '')
          #dir, name, format = split_path path
          unless @wiki.repo.bare
            Dir.chdir(::File.join(@wiki.repo.path, "..")) do
              if contents.nil?
                @wiki.repo.git.rm(path, :force => true)
              else
                @wiki.repo.git.checkout(path, 'HEAD')
              end
            end
          end
        end

        @wiki_manager.add_to_index(@wiki, index, sha, files)
      end

      sha = committer.commit
      log_debug "sha #{sha}"
    end
  end
end
