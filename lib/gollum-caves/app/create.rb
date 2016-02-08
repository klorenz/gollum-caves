module Precious
  class App
    get '/create/*' do
      forbid unless @allow_editing
      @filename = params[:splat].first.gsub('+', '-')
      wikip = wiki_page(@filename)
      #@name = wikip.name.to_url
      @name = wikip.name
      @format = params[:format].to_s

      puts "create 1 name #{@name}, path #{@path}, ext #{@format}"

      if @format.empty?
        @format = ::File.extname(@filename)[1..-1].to_s
        @name = ::File.basename(@filename, "."+@format)
        if @format.empty?
          @format = "markdown"
        end
      end

      puts "create 2 name #{@name}, path #{@path}, ext #{@format}"
      # ext = ::File.extname(@filename)
      #
      # if ext == ""
      #   ext  = ".md"
      #   wikip = wiki_page("#{@filename}")
      # end

      @path = wikip.path

      if @format == "markdown"
        @editor = "editor_markdown"
      elsif @format == "svg"
        @editor = "editor_svg"
      # if is textfile
      elsif wikip.name.match(/\.(txt|rst|css|less|js|coffee|c|cpp|cxx|h|hpp|hxx)$/)
        @editor = "editor_source"
      else
        @editor = "editor_upload"
      end

      puts "create name #{@name}, path #{@path}, ext #{@format}, editor: #{@editor}"
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
      #@path = @path.gsub(/^\/#{@wikipath}/, '')
      # @path = "/#{@wikipath}#{@path}"

      page = wikip.page
      if page
        page_dir = settings.wiki_options[:page_file_dir].to_s
        redirect to(clean_url(page.escaped_url_path))
      else
        @redirect_url = request.referer
        mustache :create
      end
    end

    post '/create' do
      name   = params[:page]
      path   = sanitize_empty_params(params[:path]) || ''
      format = params[:format].to_s.to_sym
      wikipath = params[:wikipath].to_s

      log_debug("create: name=#{name}, path=#{path}, format=#{format}, wikipath=#{wikipath}")

      # convert title to pagename
      name = Gollum::Page.cname(name)

      # add extension by format, if not given
      ext = ::File.extname(name)
      if ext.empty?
        ext = "."+settings.gollum_caves[:format_exts][format].to_s
        name = "#{name}#{ext}"
      end

      # have full name
      fullname = "#{path}/#{name}#{ext}"

      # get the wiki
      wiki = @wm.wiki(wikipath)

      # try to get the file
      wikifile = wiki.wikifile(fullname)

      # store if not yet exists
      if wikifile.nil?
        begin
          wiki.commit_files(
            author: session['gollum.author'],
            message: params[:message],
            # parent:
            files: {
              fullname => params[:content]
            }
          )

          redirect to clean_path "/view/#{wikipath}/#{fullname}"

        rescue Gollum::DuplicatePageError => e
          @message = "Duplicate page: #{e.message}"
          mustache :error
        end
      end
    end

  end
end
