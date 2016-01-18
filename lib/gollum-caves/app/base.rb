
module Valuable
  class App

    def wiki_new(collection, name=nil, opts=nil)
      if name.nil?
        if collection[0] == '/'
          collection = collection[1..-1]
          collection, name = collection.split('/')
        end
      end
      if settings.wiki_options[:repo_is_bare]
        repo_name = "#{name}.git"
      else
        repo_name = name
      end
      repo_path = ::File.join(settings.gollum_path, collection, repo_name)
      puts("wiki_new: #{collection}, #{name}, #{repo_name}, #{repo_path}")
      @wikicoll = collection
      @wikiname = name
      @wikipath = "#{collection}/#{name}"
      puts("wiki_new: #{@wikicoll}, #{@wikiname}, #{@wikipath}")

      if opts.nil?
        options = settings.wiki_options
      else
        options = settings.wiki_options.merge(opts)
      end
      options = options.merge({ :base_path => "/#{@wikipath}" })
      Gollum::Wiki.new(repo_path, options)
    end

    def wiki_page(name, path = nil, version = nil, exact = true, coll = nil, wikiname = nil)
      path = name if path.nil?
      path = extract_path(path)
      path = '/' if exact && path.nil?

      puts "1 coll: #{coll}, wikiname: #{wikiname}, path: #{path}"

      coll = coll.to_s
      wikiname = wikiname.to_s

      if coll.empty? or wikiname.empty?
        if path == "/"
          coll = @wiki_base
          name = @wiki_home
        else
          if path[0] == '/'
            path = path[1..-1]
          end

          puts "here"
          coll, wikiname, path = path.split('/', 3)
          path = '/' if path.nil? or path.empty?
        end
      end

      puts "2 coll: #{coll}, wikiname: #{wikiname}, path: #{path}"
      wiki = wiki_new(coll, wikiname)
      name = extract_name(name) || wiki.index_page

      if path[-1] == "/"
        filepath = "#{path}#{name}"
      else
        filepath = "#{path}/#{name}"
      end

      OpenStruct.new(:wiki => wiki, :page => wiki.paged(name, path, exact, version),
                     :name => name, :path => path,
                     :filepath => filepath[1..-1],
                     :collection => coll, :wikiname => wikiname)
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

      if page = wiki.paged(name, path, exact = true)
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

        mustache :page
      elsif file = wiki.file(wikip.filepath, wiki.ref, false)
        ext = ::File.extname(fullpath)

        puts "file: #{ext}, #{file}"

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
        #   @h1_title      = wiki.h1_title
        #   @bar_side      = wiki.bar_side
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
        redirect to("/create/#{clean_url(encodeURIComponent(page_path))}")
      end
    end

    # Set defaults for wiki farm
    before do
      @wiki_base = 'wiki'
      @wiki_home = "home"
      @wiki_collection = @wiki_base
      @wiki_name = @wiki_home
      @wiki_url = @base_url # clean_url(::File.join(@base_url, @wiki_collection, @wiki_name))
    end
  end
end
