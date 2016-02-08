require 'gollum-lib/committer'

module Precious
  class App

    get '/' do
      redirect to clean_url "/view/" + @wm.get_default_page()
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

      ext = ::File.extname(@name)

      if ext == ".md" or ext.empty?
        @editor = "markdown"
      elsif ext == ".svg"
        @editor = "svg"
      # if is textfile
      elsif wikip.name.match(/\.(txt|rst|css|less|js|coffee|c|cpp|cxx|h|hpp|hxx)$/)
        @editor = "source"
      else
        @editor = "upload"
      end
      wiki = wikip.wiki

      puts "edit 2 name #{@name}, path #{@path}, ext #{ext}, editor: #{@editor}, wikip.filepath #{wikip.filepath}"
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
          @page.version = wiki.repo.log(wiki.ref, @page.path).first
          mustache :edit
        else
          @editor_upload = true
          mustache :edit
        end
      else
        redirect to("/create/#{encodeURIComponent(@name)}")
      end
    end

    get '/wiki-create/:coll/:wiki' do
      #wiki_manager
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
          redirect_url = "/#{wikip.filepath}"
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

    post '/uploadFile/:coll/:wiki' do
      wiki = wiki_new(params[:coll], params[:wiki])

      unless wiki.allow_uploads
        @message = "File uploads are disabled"
        mustache :error
        return
      end

      if params[:file]
        fullname = params[:file][:filename]
        tempfile = params[:file][:tempfile]
      end
      halt 500 unless tempfile.is_a? Tempfile

      # Remove page file dir prefix from upload path if necessary -- committer handles this itself
      dir      = wiki.per_page_uploads ? params[:upload_dest].match(/^(#{wiki.page_file_dir}\/+)?(.*)/)[2] : 'uploads'
      ext      = ::File.extname(fullname)
      format   = ext.split('.').last || 'txt'
      filename = ::File.basename(fullname, ext)
      contents = ::File.read(tempfile)
      reponame = filename + '.' + format

      head = wiki.repo.head

      options = {
          :message => "Uploaded file to #{dir}/#{reponame}",
          :parent  => wiki.repo.head.commit,
      }
      author  = session['gollum.author']
      unless author.nil?
        options.merge! author
      end

      begin
        committer = Gollum::Committer.new(wiki, options)
        committer.add_to_index(dir, filename, format, contents)
        committer.after_commit do |committer, sha|
          wiki.clear_cache
          committer.update_working_dir(dir, filename, format)
        end
        committer.commit
        redirect to(request.referer)
      rescue Gollum::DuplicatePageError => e
        @message = "Duplicate page: #{e.message}"
        mustache :error
      end
    end

    # edit or delete metadata in a page
    post '/metadata/:coll/:wiki/*' do
      action = params[:action]
      action = 'update' if action.nil?

#      params = JSON.parse(request.env["rack.input"].read).merge(params)

    end



    get '/view/*' do
      show_page_or_file2(params[:splat].first)
    end

    get '/*' do
      show_page_or_file(params[:splat].first)
    end


    # get '/view/:collname/:wikiname/*' do
    #   collname = params[:collname]
    #   wikiname = params[:wikiname]
    #   filepath = params[:splat].first
    #
    #   render_wikifile(collname, wikiname, filepath)
    # end
    #
    # def render_wikifile(collname, wikiname, filepath)
    #   wikifile = @wm.wiki(collname, wikiname).wikifile(filename)
    #   if page = wikifile.as_page()
    #     @page = page
    #     @name = wikifile.name
    #     @content = page.formatted_data
    #     @upload_dest = find_upload_dest(filepath)
    #     @editable    = true
    #     @page_exists = !page.versions.empty?
    #     mustache :page
    #   end
    #     #@toc_content = @
    # end
  end
end
