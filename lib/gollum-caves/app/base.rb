require 'gollum-caves/wiki_manager'
module Precious
  class App

    def wiki_new(collection, name=nil, opts=nil)
      wiki = @wm.wiki(collection, name, opts)
      @wikipath = wiki.base_path[1..-1]
      @wikicoll, @wikiname = @wikipath.split('/')
      wiki
    end

    def wiki_page(name, path = nil, version = nil, exact = true, coll = nil, wikiname = nil)
      path = name if path.nil?

      cn, wn, pn = @wm.split_wiki_path path
      log_debug("wiki_page: path=#{path}, cn=#{cn}, wn=#{wn}, pn=#{pn}")
      path = extract_path(path)
      path = '/' if exact && path.nil?

      begin
        wiki = wiki_new(cn, wn)
      rescue
        if cn != @wm.default_coll_name and wn != @wm.meta_wiki_name

          redirect to(clean_url("/view/#{@wm.default_coll_name}/#{@wm.meta_wiki_name}/Getting-Started"))
        else
          raise
        end
      end

      name = extract_name(name) || wiki.index_page

      if path[-1] == "/"
        filepath = "#{path}#{name}"
      else
        filepath = "#{path}/#{name}"
      end

      if path[0] == "/"
        filepath = filepath[1..-1]
      end

      OpenStruct.new(:wiki => wiki,
                     :page => wiki.paged(name, path, exact, version),
                     :name => name,
                     :path => path,
                     :filepath => filepath,
                     :collection => coll,
                     :wikiname => wikiname)
    end

    def show_page_or_file(fullpath)
      log_debug "show_page_or_file: #{fullpath}"

      wikip = wiki_page(fullpath)
      wiki = wikip.wiki

      name = extract_name(fullpath) || wiki.index_page
      log_debug "name: #{name}, filepath: #{wikip.filepath}"
      path = wikip.path

      file = wiki.file(wikip.filepath[1..-1], wiki.ref, false)

      log_debug "file: #{file}"

      if page = wiki.paged(name, path, true)
        log_debug "page: #{page}"
        @page          = page
        @name          = name
        @content       = page.formatted_data
        @source        = page.text_data
        @upload_dest   = find_upload_dest(path)

        # Extensions and layout data
        @editable      = true
        @page_exists   = !page.versions.empty?
        @toc_content   = wiki.universal_toc ? @page.toc_data : nil
        @mathjax       = wiki.mathjax
        @h1_title      = wiki.h1_title
        @bar_side      = wiki.bar_side
        @allow_uploads = wiki.allow_uploads

        @attachments = []
        if @page_exists
          att_wiki = wiki_new(wikip.collection, wikip.wikiname, { :page_file_dir => [wikip.path, wikip.page.filename_stripped].join('/') })
          @attachments = att_wiki.files
        end
        @has_attachments = !@attachments.empty?

        mustache :page
      elsif file = wiki.file(wikip.filepath, wiki.ref, false)
        #ext = ::File.extname(fullpath)

        # if ext == ".svg"
        #   @page          = file
        #   @name          = name
        #   @content       = file.raw_data
        #   @upload_dest   = find_upload_dest(path)
        #
        #   # Extensions and layout data
        #   @editable      = true
        #   @page_exists   = !page.versions.empty?
        #   @toc_content   = ""
        #   @mathjax       = wiki.mathjax
        #   @allow_uploads = wiki.allow_uploads
        #
        #   mustache :page
        #
        # else
          show_file(file)
        # end

      else
        not_found unless @allow_editing
        if path[0] == '/'
          path = path[1..-1]
        end
        page_path = [@wikipath, path, name].compact.join('/')
        log_debug "wikipath #{@wikipath}, path #{path}, name #{name}, page_path: #{page_path}"
        redirect to("/create/#{clean_url(encodeURIComponent(page_path))}")
      end
    end

    def show_page_or_file2(fullpath)
      begin
        wikifile = @wm.wikifile(fullpath)
      rescue
        log_error "error getting wikifile #{fullpath}"
      end

      if wikifile.nil?
        if fullpath[0] == '/'
          fullpath = fullpath[1..-1]
        end
        redirect to("/create/#{fullpath}")

      elsif page = wikifile.as_page
        @page = page
        @name = page.name
        @content = page.formatted_data
        @source  = page.text_data
        @upload_dest = find_upload_dest(wikifile.path)
        @editable    = true
        @page_exists = true
        @mathjax     = wikifile.wiki.mathjax
        @h1_title      = wikifile.wiki.h1_title
        @bar_side      = wikifile.wiki.bar_side
        @allow_uploads = wikifile.wiki.allow_uploads
        @attachments   = []
        log_debug("page.path: #{page.path}")
        @has_attachments = !@attachments.empty?
        #@wikifile.wiki.list_dir("#{page.path}")

        mustache :page
      else
        show_file wikifile.as_file
      end
    end

    # Public: show a Gollum::File object
    def show_file(file)
      return unless file
      if file.on_disk?
        send_file file.on_disk_path, :disposition => 'inline'
      else
        content_type file.mime_type
        file.raw_data
      end
    end

    # # Set defaults for wiki farm
    # before do
    #   default = ENV['WIKI_DEFAULT']
    #
    #   if not default.nil?
    #     @wiki_base, @wiki_home = default.split('/')
    #   else
    #     @wiki_base = 'wiki'
    #     @wiki_home = "me"
    #   end
    #
    #   @wiki_collection = @wiki_base
    #   @wiki_name = @wiki_home
    #
    #   # values from kj
    #
    # end
  end
end
