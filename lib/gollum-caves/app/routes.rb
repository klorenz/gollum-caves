require 'gollum-lib/committer'

module Valuable
  class App
    get '/' do
      redirect clean_url(::File.join(@base_url, @wiki_base, @wiki_home, @page_dir, wiki_new(@wiki_base, @wiki_home).index_page))
    end

    get '/latest_changes/:coll/:wiki' do
      @wiki = wiki_new(params[:coll], params[:wiki])
      max_count = settings.wiki_options.fetch(:latest_changes_count, 10)
      @versions = @wiki.latest_changes({:max_count => max_count})
      mustache :latest_changes
    end

    # get wikifarm information /<collection>/<name> and melt down path_info
    # before '/:coll/:name/*' do
    #   if params[:coll] != "javascript" and params[:coll] != "css" and params[:coll] != "gollum-caves"
    #     @wiki_collection = params[:coll]
    #     @wiki_name       = params[:name]
    #     @wiki_url = clean_url(::File.join(@base_url, @wiki_collection, @wiki_name))
    #     request.path_info = "/#{params[:splat].first}"
    #   end
    # end

    get '/data/*' do
      # @wiki_collection = params[:coll]
      # @wiki_name = params[:name]
      # @page_name = params[:splat].first

      #if @page_name.match(/\.json$/)
        # return a json with additional info about page
      if page = wiki_page(params[:splat].first).page
        page.raw_data
      end
      # elsif file = wiki.file(fullpath, wiki.ref, true)
      #   show_file(file)

    end

    get '/edit/*' do
      forbid unless @allow_editing
      wikip        = wiki_page(params[:splat].first)
      @name        = wikip.name
      @filename    = wikip.name
      @path        = wikip.path
      @upload_dest = find_upload_dest(@path)

      @editor_markdown = false
      @editor_svg      = false
      @editor_source   = false
      @editor_upload   = false

      ext = ::File.extname(@name)

      if ext == ".md" or ext.empty?
        @editor_markdown = true
      elsif ext == ".svg"
        @editor_svg = true
      # if is textfile
      elsif wikip.name.match(/\.(txt|rst|css|less|js|coffee|c|cpp|cxx|h|hpp|hxx)$/)
        @editor_source = true
      else
        @editor_upload = true
      end
      wiki = wikip.wiki

      puts "edit 2 name #{@name}, path #{@path}, ext #{ext}, editor_markdown: #{@editor_markdown}, wikip.filepath #{wikip.filepath}"
      file = wiki.file(wikip.filepath, wiki.ref, false)
      puts "edit 2 file: #{file}"

      @redirect_url = request.referer

      if page = wikip.page
        @page         = page
        @page.version = wiki.repo.log(wiki.ref, @page.path).first
        @content      = page.text_data
        mustache :edit
      elsif file = wiki.file(wikip.filepath, wiki.ref, false)
        ext = ::File.extname(wikip.filepath)
        if @editor_svg
          @page = file
          @title = wikip.name
          @content = file.raw_data
          mustache :edit
        else
          @editor_upload = true
          mustache :edit
        end
      else
        redirect to("/create/#{@wikipath}/#{encodeURIComponent(@name)}")
      end
    end

    get '/wiki-create/:coll/:wiki' do
      # forbid unless @allow_manage_wiki(params[:coll])
      # wiki_dir = ::File.join(settings.gollum_path, params[:coll], params[:wiki])
      # output = `mkdir -p #{wiki_dir} ; cd #{wiki_dir} ; git init`
      #
      # mustache :created_wiki
      # #redirect to("/wiki/me/manage-wiki?wiki=#{params[:coll]}/#{params[:wiki]}")
    end

    get '/wiki-fork/:coll/:wiki' do
#      forbid unless @allow_read_wiki(params[:coll], params[:wiki])
    end

    get '/wiki-rename/:src_coll/:src_wiki/to/:dst_coll/:src' do
#      forbid unless @allow_read_wiki(params[:coll], params[:wiki])
    end

    get '/create/*' do
      forbid unless @allow_editing
      @filename = params[:splat].first.gsub('+', '-')
      wikip = wiki_page(@filename)
      @name = wikip.name.to_url
      format = params[:format].to_s

      puts "create 1 name #{@name}, path #{@path}, ext #{format}"

      if format.empty?
        format = ::File.extname(@filename)[1..-1].to_s
        @name = ::File.basename(@filename, "."+format).to_url
        if format.empty?
          format = "markdown"
        end
      end

      puts "create 2 name #{@name}, path #{@path}, ext #{format}"
      # ext = ::File.extname(@filename)
      #
      # if ext == ""
      #   ext  = ".md"
      #   wikip = wiki_page("#{@filename}")
      # end

      @path = wikip.path

      @editor_markdown = false
      @editor_svg      = false
      @editor_source   = false
      @editor_upload   = false

      if format == "markdown"
        @editor_markdown = true
      elsif format == "svg"
        @editor_svg = true
      # if is textfile
      elsif wikip.name.match(/\.(txt|rst|css|less|js|coffee|c|cpp|cxx|h|hpp|hxx)$/)
        @editor_source = true
      else
        @editor_upload = true
      end

      puts "create name #{@name}, path #{@path}, ext #{format}, editor_markdown: #{@editor_markdown}"
      @allow_uploads = wikip.wiki.allow_uploads
      @upload_dest   = find_upload_dest(@path)

      page_dir = settings.wiki_options[:page_file_dir].to_s
      unless page_dir.empty?
        # --page-file-dir docs
        # /docs/Home should be created in /Home
        # not /docs/Home because write_page will append /docs
        @path = @path.sub(page_dir, '/') if @path.start_with? page_dir
      end
      @path = clean_path(@path)
      @path = "/#{@wikipath}#{@path}"

      page = wikip.page
      if page
        page_dir = settings.wiki_options[:page_file_dir].to_s
        redirect to("/#{@wikipath}/#{clean_url(::File.join(page_dir, page.escaped_url_path))}")
      else
        @redirect_url = request.referer
        mustache :create
      end
    end

    post '/edit/*' do
      path      = '/' + clean_url(sanitize_empty_params(params[:path])).to_s
      wikipath  = params[:wikipath].to_s
      page_name = CGI.unescape(params[:page])

      puts "post edit path #{path}, page_name #{page_name}, wikipath #{wikipath}"
      puts "post pagepath #{wikipath}#{path}"

      wikip     = wiki_page(page_name, wikipath+path, nil, exact = true)
      wiki      = wikip.wiki
      page      = wikip.page

      if page.nil?
        file = wiki.file(wikip.filepath, )
        return if file.nil?

        committer = Gollum::Committer.new(wiki, commit_message)
        commit = { :committer => committer }
        puts "post edit path #{wikip.path}, page_name #{wikip.name}, wikipath #{params[:format]}"
        update_wiki_page(wiki, file, params[:content], commit, wikip.name, params[:format])
        committer.commit

        if not params[:redirect].nil?
          redirect_url = params[:redirect]
        else
          redirect_url = "/#{@wikipath}/#{wikip.filepath}"
        end

        puts("redirect_url: #{redirect_url}")

        redirect to(redirect_url)
      else
        committer = Gollum::Committer.new(wiki, commit_message)
        commit    = { :committer => committer }

        update_wiki_page(wiki, page, params[:content], commit, page.name, params[:format])
        update_wiki_page(wiki, page.header, params[:header], commit) if params[:header]
        update_wiki_page(wiki, page.footer, params[:footer], commit) if params[:footer]
        update_wiki_page(wiki, page.sidebar, params[:sidebar], commit) if params[:sidebar]
        committer.commit
      end

      redirect to("/#{@wikipath}/#{page.escaped_url_path}") unless page.nil?
    end

    get '/fileview/:coll/:wiki' do
      wiki     = wiki_new(params[:coll], params[:wiki])
      options  = settings.wiki_options
      content  = wiki.pages
      # if showing all files include wiki.files
      content  += wiki.files if options[:show_all]

      # must pass wiki_options to FileView
      # --show-all and --collapse-tree can be set.
      @results = Gollum::FileView.new(content, options).render_files
      @ref     = wiki.ref
      mustache :file_view, { :layout => false }
    end

    get '/pages/:coll/:wiki/*' do
      path = params[:splat].first.to_s
      @path = extract_path(path) if path

      wiki = wiki_new(params[:coll], params[:wiki], { :page_file_dir => @path })

      @results     = wiki.pages
      @results     += wiki.files if settings.wiki_options[:show_all]
      @results     = @results.sort_by { |p| p.name.downcase } # Sort Results alphabetically, fixes 922
      @ref         = wiki.ref
      mustache :pages
    end


    get '/pages/:coll/:wiki' do
      redirect to("/pages/#{params[:coll]}/#{params[:wiki]}/")
    end

    post '/create' do
      name   = params[:page].to_url
      path   = sanitize_empty_params(params[:path]) || ''

      format = params[:format].to_s

      wikip  = wiki_page(name, path)
      wiki   = wikip.wiki
      path   = wikip.path

      puts "1 name: '#{name}'"

      path.gsub!(/^\//, '')

      ext = ::File.extname(name)
      if format.empty?
        if ext == ""
          format = :markdown
        elsif ext == ".md"
          format = :markdown
          name = ::File.basename(name)
        else
          format = ext[1..-1]
          name = ::File.basename(name)
        end
      else
        if ext != ""
          name = ::File.basename(name)
        end
      end
      # #   name = "#{name}.#{ext}"
      # #   format = :markdown
      # # else
      # #   format = ext
      # # end
      #
      # if format == "svg"
      #   filename = name
      #   if ::File.extname(filename) != format
      #     filename = "#{filename}.#{format}"
      #   end
      #
      #   options = {
      #     :message => "Edited SVG file",
      #     :parent  => wiki.repo.head.commit,
      #   }
      #   author = session['gollum.author']
      #   unless author.nil?
      #     options.merge! author
      #   end
      #
      #   begin
      #     committer = Gollum::Committer.new(wiki, options)
      #     puts "committer: #{committer}"
      #     committer.add_to_index(path, filename, format, params[:content])
      #     committer.after_commit do |committer, sha|
      #       wiki.clear_cache
      #       committer.update_working_dir(dir, filename, format)
      #     end
      #     committer.commit
      #     redirect to(request.referer)
      #   rescue Gollum::DuplicatePageError => e
      #     @message = "Duplicate page: #{e.message}"
      #     mustache :error
      #   end
      # else
      puts "2 name: '#{name}', format: '#{format}', path: '#{path}'"
      begin
        wiki.write_page(name, format, params[:content], commit_message, path)

        page_dir = settings.wiki_options[:page_file_dir].to_s
        redirect to("/#{wikip.collection}/#{wikip.wikiname}/#{clean_url(::File.join(page_dir, path, encodeURIComponent(name)))}")
      rescue Gollum::DuplicatePageError => e
        @message = "Duplicate page: #{e.message}"
        mustache :error
      end
    end
  end
end
