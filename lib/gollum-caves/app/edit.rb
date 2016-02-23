module Precious
  class App

    get '/edit/*' do
      forbid unless @allow_editing
      fullpath = Gollum::Page.cname(params[:splat].first)
      wikifile = @wm.wikifile(fullpath)

      log_debug("wikifile: #{wikifile}")

      if wikifile.nil?
        redirect to "/create/#{params[:splat].first}"
      else
        @redirect_url = request.referer
        @name         = wikifile.name
        log_debug("name: #{@name}")
        @filename     = wikifile.filename
        @path         = wikifile.dir
        @upload_dest  = wikifile.filename.gsub(/\.[^.]+$/, '')

        @editor = wikifile.editor
        @content = wikifile.content

        log_debug("editor: #{@editor}")

        @page = wikifile
        @title = wikifile.title
        @wikicoll = wikifile.wiki.collname
        @wikiname = wikifile.wiki.wikiname
        @wikipath = wikifile.wiki.collname

        mustache :edit
      end
    end

    post '/edit/*' do
      splat_path = params[:splat].first

      path      = clean_url(sanitize_empty_params(param[:path])).to_s
      wikipath  = params[:wikipath].to_s
      page_name = CGI.unescape(params[:page])
      version   = params[:version].to_s

      if path.empty? or page_name.empty? or wikipath.empty?
        if splat_path.nil? or splat_path.empty?
          raise "No path given"
        end

        fullname = @Gollum::Page.cname(splat_path)
      else
        fullname = "#{wikipath}/#{path}/#{page_name}"
      end

      @wikifile = @wm.wikifile(fullname)

      if @wikifile.nil?
        # show create page with passed content
      else
        @wikifile.wiki.commit_files(
          :message => params[:message],
          :parent  => version,
          :author  => session['gollum.author'],
          :files => {
            wikifile.filename => params[:content]
          },
        )
      end
    end
  end
end
