require 'gollum-caves/wiki_manager'
module Valuable
  class App

    def wiki_new(collection, name=nil, opts=nil)
      wiki = @wiki_manager.wiki(collection, name, opts)
      @wikipath = wiki.base_path[1..-1]
      @wikicoll, @wikiname = @wikipath.split('/')
      wiki
    end

    def wiki_page(name, path = nil, version = nil, exact = true, coll = nil, wikiname = nil)
      path = name if path.nil?

      cn, wn, pn = @wiki_manager.expand_wiki_parts path
      path = extract_path(path)
      path = '/' if exact && path.nil?

      begin
        wiki = wiki_new(cn, wn)
      rescue
        if cn != @default_coll and wn != @meta_wiki
          redirect to(clean_url("/#{@default_coll}/#{@meta_wiki}/Getting-Started"))
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

      OpenStruct.new(:wiki => wiki,
                     :page => wiki.paged(name, path, exact, version),
                     :name => name,
                     :path => path,
                     :filepath => filepath[1..-1],
                     :collection => coll,
                     :wikiname => wikiname)
    end

    def show_page_or_file(fullpath)
      puts "show_page_or_file: #{fullpath}"

      wikip = wiki_page(fullpath)
      wiki = wikip.wiki

      name = extract_name(fullpath) || wiki.index_page
      puts "name: #{name}, filepath: #{wikip.filepath}"
      path = wikip.path


      file = wiki.file(wikip.filepath[1..-1], wiki.ref, false)

      puts "file: #{file}"

      if page = wiki.paged(name, path, true)
        puts "page: #{page}"
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
        puts "wikipath #{@wikipath}, path #{path}, name #{name}"
        redirect to("/create/#{clean_url(encodeURIComponent(page_path))}")
      end
    end

    # Set defaults for wiki farm
    before do
      default = ENV['WIKI_DEFAULT']

      if not default.nil?
        @wiki_base, @wiki_home = default.split('/')
      else
        @wiki_base = 'wiki'
        @wiki_home = "me"
      end

      @wiki_collection = @wiki_base
      @wiki_name = @wiki_home

      # values from kj

      @wiki_manager = GollumCaves::WikiManager.new(@wiki_root, {
        :meta_wiki_name     => @meta_wiki,
        :default_collection => @default_coll,
        :default_wiki       => @default_wiki,
        })
    end
  end
end
